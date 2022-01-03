//
//  PDFGenerator.swift
//  AgriEdgeCalculatorTool
//
//  Created by lloyd on 8/5/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import TPPDF
import WebKit

protocol PDFCreation {
    func generatePDF(with grower: Grower?, from plan: Plan?, documentType: DocumentType) -> URL?
}

extension PDFCreation {
    
    func generatePDF(with grower: Grower?, from plan: Plan?, documentType: DocumentType) -> URL? {
        guard let growerFound = grower, let planFound = plan else {
            return nil
        }
        // init
        let document = PDFDocument(format: .a4)
        
        //Pull Current Date
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        let date = formatter.string(from: currentDateTime)
        
        // Document General Formatting
        document.info.title = "\(growerFound.farmName) - \(planFound.displayName) - \(documentType.documentName)".replacingOccurrences(of: "/", with: "")
        document.info.subject = "Generated Reward Plan for \(growerFound.farmName)"
        document.layout.margin = UIEdgeInsets(top: 20, left: 30, bottom: 5, right: 30)
        document.set(font: UIFont.systemFont(ofSize: 11.0))
        
        // Title table
        var titleTableContent = [[PDFTableContentable?]]()
        switch documentType {
        case .estimate:
            titleTableContent = [[UIImage(named: "AgriEdge2019_logl") ?? UIImage(), " "]]
        case .cropPlan:
            titleTableContent = [[UIImage(named: "AgriEdge2019_logl") ?? UIImage(), "Crop Plan"]]
        }
        let titleTable = PDFTable(rows: titleTableContent.count, columns: 2)
        titleTable.content = titleTableContent
        titleTable.style.columnHeaderCount = 0
        titleTable.style.rowHeaderCount = 2
        titleTable.style.outline = .none
        titleTable.style.rowHeaderStyle.font = .systemFont(ofSize: 30.0)
        titleTable.widths = [0.50, 0.50]
        titleTable.rows.allRowsAlignment = [.left, .center]
        document.add(table: titleTable)
        
        document.add(space: 10.0)
        
        // Name table
        guard let userData = PersistenceLayer().fetch(UserObject.self)?.first else { return nil }
        let user = User(userObject: userData),
            specialistName = "\(user.firstName) \(user.lastName)"
        var nameTableContent = [[PDFTableContentable?]]()
        nameTableContent.append(contentsOf: [
            ["Specialist", specialistName],
            ["AgriEdge Zone", growerFound.zoneID.zoneDisplayNameFromID()]] )
        let nameTable = PDFTable(rows: nameTableContent.count, columns: 2)
        nameTable.style.columnHeaderCount = 0
        nameTable.style.rowHeaderCount = 2
        nameTable.style.outline = .none
        nameTable.style.rowHeaderStyle.font = .systemFont(ofSize: 11.0)
        nameTable.widths = [0.70, 0.30]
        nameTable.content = nameTableContent
        nameTable.rows.allRowsAlignment = [.left, .left]
        document.add(table: nameTable)
        document.add(space: 10.0)

        // Calculated Summary Tables
        var cpRiskTableContent = [[PDFTableContentable?]]()
        var seedRiskTableContent = [[PDFTableContentable?]]()
        switch documentType {
        case .estimate:
            cpRiskTableContent.append(contentsOf: [
                ["Cropsurance 10/90", planFound.rebate.tenNinetyCropsurance],
                ["Target 50/50", planFound.rebate.fiftyFiftyTarget],
                ["CAP", planFound.rebate.capRiskManagement]])
            seedRiskTableContent.append(contentsOf: [
                ["Cropsurance 5/95", planFound.rebate.seedFiveNinetyFiveCropsurance],
                ["Target 20/80", planFound.rebate.seedTwentyEightyTarget],
                ["CAP", planFound.rebate.seedCapRiskManagement]])
        case .cropPlan:
            break
        }

        let cpRiskTable = PDFTable(rows: cpRiskTableContent.count, columns: 2)
        let seedRiskTable = PDFTable(rows: seedRiskTableContent.count, columns: 2)
        // Table Styling
        switch documentType {
        case .estimate:
            cpRiskTable.style.columnHeaderCount = 0
            cpRiskTable.style.rowHeaderCount = 2
            cpRiskTable.style.outline = .none
            cpRiskTable.style.rowHeaderStyle.font = .systemFont(ofSize: 11.0)
            cpRiskTable.widths = [0.70, 0.30]
            seedRiskTable.style.columnHeaderCount = 0
            seedRiskTable.style.rowHeaderCount = 2
            seedRiskTable.style.outline = .none
            seedRiskTable.style.rowHeaderStyle.font = .systemFont(ofSize: 11.0)
            seedRiskTable.widths = [0.70, 0.30]
        case .cropPlan:
            break
        }
        //Add the Summaries
        switch documentType {
        case .estimate:
            document.add(attributedText: NSMutableAttributedString(string: "Crop Protection Cost-Share Spend: \(planFound.rebate.estimatedSpend)", attributes: [.font: UIFont.boldSystemFont(ofSize: 13.0)]))
            document.add(space: 10.0)
            cpRiskTable.content = cpRiskTableContent
            cpRiskTable.rows.allRowsAlignment = [.left, .left]
            document.add(table: cpRiskTable)
            document.add(space: 10.0)
        case .cropPlan:
            break
        }
        
        // Add the Calculated For, Prepared On
        
        document.add(attributedText: NSMutableAttributedString(string: "Calculated For:   \(growerFound.farmName)", attributes: [.font: UIFont.boldSystemFont(ofSize: 13.0)]))
        document.add(space: 2.0)
        document.add(attributedText: NSMutableAttributedString(string: "Prepared On:       \(date)", attributes: [.font: UIFont.systemFont(ofSize: 13.0)]))
        document.add(space: 20.0)
        
        // Add table(s) for each crop
        for plantedCrop in growerFound.crops ?? [] {
            let planHasApplications = planFound.applications.contains(where: { $0.cropID == plantedCrop.cropID})
            let planHasSeedApplications = planFound.seedApplications.contains(where: { $0.cropID == plantedCrop.cropID})
            guard planHasApplications || planHasSeedApplications else { continue }
            
            let cropTitleString = "\(plantedCrop.cropID.cropNameFromID() ?? "")         \(plantedCrop.plantedAcreage) Acres"
            document.add(attributedText: NSMutableAttributedString(string: cropTitleString, attributes: [.font: UIFont.boldSystemFont(ofSize: 17.0)]))
            document.add(space: 10.0)
            
            // CropProtection
            if planHasApplications {
                // If any Application has AgriClime selected, include that column in the table
                let includeAgriClimeInfo = !planFound.applications.filter { $0.cropID == plantedCrop.cropID }.filter { $0.enrollInAgriClime == 1 }.isEmpty
                let numColumns = includeAgriClimeInfo ? 6 : 5
                let defaultFont = UIFont.boldSystemFont(ofSize: 12.0)
                var cpTableColumns = [ NSMutableAttributedString(string: "Product", attributes: [
                                                                    .font: UIFont.boldSystemFont(ofSize: 17.0)]),
                                       NSMutableAttributedString(string: "Rate/Acre", attributes: [.font: defaultFont]),
                                       NSMutableAttributedString(string: "Applied Acres", attributes: [.font: defaultFont]),
                                       NSMutableAttributedString(string: "Coverage", attributes: [.font: defaultFont]),
                                       NSMutableAttributedString(string: "Total Product", attributes: [.font: defaultFont])]
                if includeAgriClimeInfo {
                    cpTableColumns.append(NSMutableAttributedString(string: "AgriClime Quantity", attributes: [.font: defaultFont]))
                }
                var cpTableContent: [[PDFTableContentable?]] =  [cpTableColumns]
                var estimatedSpendTotalByCrop = 0.0
                // CropProtection applications
                for application in planFound.applications where application.cropID == plantedCrop.cropID {
                    let productName = application.productID.productNameFromID() ?? ""
                    let rate = "\(application.appliedRate) \(application.appliedUoM.rateDisplayName)"
                    let appliedAcres = application.appliedAcreage
                    let percentageOfTotalCrop = (Double(application.appliedAcreage) ?? 0.0) / plantedCrop.plantedAcreage
                    let totalProduct = (Double(application.appliedRate) ?? 0.0) * (Double(application.appliedAcreage) ?? 0.0) / application.appliedUoM.ratio
                    let coverage = "\(String(format: "%.0f", percentageOfTotalCrop * 100))%"
                    let totalProductString = "\(String(format: "%.0f", totalProduct)) \(application.appliedUoM.topLevelTotalDisplayName)"
                    let agriClimeQuantity = application.agriClimeQuantity ?? ""
                    let agriClimeQuantityString = "\(agriClimeQuantity) \(application.appliedUoM.topLevelTotalDisplayName)"
                    let associatedProductPrice = application.productID.productPriceFromID(zoneID: grower?.zoneID ?? "")
                    var rowContent = [productName, rate, appliedAcres, coverage, totalProductString]
                    if includeAgriClimeInfo {
                        rowContent.append(agriClimeQuantityString)
                    }
                    cpTableContent.append(rowContent)
                    let safeAssociatedProductPrice = (associatedProductPrice ?? 0.0)
                    let applicationSpendTotal = totalProduct * safeAssociatedProductPrice
                    estimatedSpendTotalByCrop += applicationSpendTotal
                }
                //Calculate total spend per acre
                let estimatedSpendRateByCrop = estimatedSpendTotalByCrop / plantedCrop.plantedAcreage

                if !cpTableContent.isEmpty {
                    let cpTable = PDFTable(rows: cpTableContent.count, columns: numColumns)
                    cpTable.style.rowHeaderCount = 0
                    cpTable.style.footerCount = 0
                    cpTable.style.outline = .none
                    cpTable.style.columnHeaderStyle.colors = (.white, .black)
                    cpTable.content = cpTableContent
                    let columnWidth = 1.0 / CGFloat(numColumns)
                    cpTable.widths = Array(repeating: columnWidth, count: numColumns)
                    cpTable.rows.allRowsAlignment = Array(repeating: .right, count: numColumns)
                    document.add(table: cpTable)
                    document.add(space: 10.0)
                }
                switch documentType {
                case .estimate:
                    let estimatedSpendRateByCropName = estimatedSpendRateByCrop.currencyString()
                    document.add(.contentRight, text: "Crop Estimated Spend/Acre: \(estimatedSpendRateByCropName)")
                    document.add(space: 5.0)
                    let estimatedSpendTotalByCropName = estimatedSpendTotalByCrop.currencyString()
                    document.add(.contentRight, text: "Crop Estimated Spend: \(estimatedSpendTotalByCropName)")
                    document.add(space: 2.0)
                case .cropPlan:
                    break
                }
            }
            
            document.add(space: 10.0)

            // Seeds
            if planHasSeedApplications {
                let numColumns = 5
                let defaultFont = UIFont.boldSystemFont(ofSize: 12.0)
                var seedTableContent: [[PDFTableContentable?]] =  [[ NSMutableAttributedString(string: "Seed", attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 17.0)]),
                                                NSMutableAttributedString(string: "Rate/Acre", attributes: [.font: defaultFont]),
                                                NSMutableAttributedString(string: "Applied Acres", attributes: [.font: defaultFont]),
                                                NSMutableAttributedString(string: "Coverage", attributes: [.font: defaultFont]),
                                                NSMutableAttributedString(string: "Total Seed", attributes: [.font: defaultFont])]]
                var estimatedSpendRateByCrop = 0.0
                var estimatedSpendTotalByCrop = 0.0
                // Seed applications
                for seedApplication in planFound.seedApplications where seedApplication.cropID == plantedCrop.cropID {
                    let seedName = seedApplication.seedID.seedNameFromID() ?? ""
                    let rate = "\(seedApplication.appliedRate) \(seedApplication.appliedUoM.rateDisplayName)"
                    let appliedAcres = seedApplication.appliedAcreage
                    let percentageOfTotalCrop = (Double(seedApplication.appliedAcreage) ?? 0.0) / plantedCrop.plantedAcreage
                    var totalSeedInBags = (Double(seedApplication.appliedRate) ?? 0.0) * (Double(seedApplication.appliedAcreage) ?? 0.0) //this value is in selected unit
                    if seedApplication.appliedUoM != .bag { //if seed/kernel, we need to convert it
                        totalSeedInBags = totalSeedInBags / seedApplication.seedID.seedStdFactorFromID() //convert to .bags
                    }
                    let coverage = "\(String(format: "%.0f", percentageOfTotalCrop * 100))%"
                    let totalSeedString = "\(String(format: "%.1f", totalSeedInBags)) \(UnitOfMeasure.bag.topLevelTotalDisplayName)"
                    let associatedSeedPrice = seedApplication.seedID.seedPriceFromID(zoneID: grower?.zoneID ?? "")
                    seedTableContent.append([seedName, rate, appliedAcres, coverage, totalSeedString])
                    let seedInBagsPerAcre = totalSeedInBags / (Double(seedApplication.appliedAcreage) ?? 1.0) //convert total into per acre value
                    estimatedSpendRateByCrop += seedInBagsPerAcre * (associatedSeedPrice ?? 0.0)
                    estimatedSpendTotalByCrop += totalSeedInBags * (associatedSeedPrice ?? 0.0)
                }
                if !seedTableContent.isEmpty {
                    let seedTable = PDFTable(rows: seedTableContent.count, columns: 5)
                    seedTable.style.rowHeaderCount = 0
                    seedTable.style.footerCount = 0
                    seedTable.style.outline = .none
                    seedTable.style.columnHeaderStyle.colors = (.white, .black)
                    seedTable.content = seedTableContent
                    let columnWidth = 1.0 / CGFloat(numColumns)
                    seedTable.widths = Array(repeating: columnWidth, count: numColumns)
                    seedTable.rows.allRowsAlignment = Array(repeating: .right, count: numColumns)
                    document.add(table: seedTable)
                    document.add(space: 10.0)
                }
                switch documentType {
                case .estimate:
                    let estimatedSpendRateByCropName = estimatedSpendRateByCrop.currencyString()
                    document.add(.contentRight, text: "Crop Estimated Spend/Acre: \(estimatedSpendRateByCropName)")
                    document.add(space: 5.0)
                    let estimatedSpendTotalByCropName = estimatedSpendTotalByCrop.currencyString()
                    document.add(.contentRight, text: "Crop Estimated Spend: \(estimatedSpendTotalByCropName)")
                    document.add(space: 2.0)
                case .cropPlan:
                    break
                }
            }
            
        }
        
        document.set(font: UIFont.systemFont(ofSize: 6.0))
        
        // Add legal
        
        document.add(space: 40.0)
        document.add(.contentCenter, attributedText: NSMutableAttributedString(string: "Legal", attributes: [.font: UIFont.boldSystemFont(ofSize: 12.0)]))
        document.add(space: 3.0)
        document.add(text: "This calculated report has been developed to provide an approximation of your AgriEdge Cost-Share Opportunity.  While every effort has been made ensure the accuracy and reliability of the information, no guarantee is given or responsibility taken by Syngenta or Ag Connections for the accuracy of the calculation.")
        document.add(space: 10.0)
        document.add(text: "SYNGENTA PROVIDES THIS REPORT AND ANY RESULT THEREFROM AS-IS, WHERE-IS, WITH ALL FAULTS AND WITH NO WARRANTY WHATSOEVER, EITHER EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF MERCHANTABILITY AND FITNESS FOR PARTICULAR PURPOSE.  YOU ASSUME ANY AND ALL RISKS IN USING THE CALCULATOR AND RELYING ON THE INFORMATION CONTAINED HEREIN.  UNDER NO CIRCUMSTANCES SHALL SYNGENTA BE LIABILE FOR ANY DAMAGES WHATSOEVER, INCLUDING BUT NOT LIMITED TO LOSS OF PROFIT, LOSS OF BUSINESS, LOSS OF SAVINGS, OR CONSEQUENTIAL DAMAGES, EVEN IF SYNGENTA HAS BEEN NOTIFIED AS SUCH.")
        document.add(space: 10.0)
        document.add(attributedText: NSMutableAttributedString(string: "Important: Always read and follow label instructions. Some products may not be registered for sale or use in all states or counties. Please check with your local extension service to ensure registration status. AAtrex 4L, AAtrex Nine-O, Acuron, Agri-Flex, Agri-Mek 0.15EC, Agri-Mek SC, Avicta 500FS, Avicta Complete Beans 500, Avicta Complete Corn 250, Avicta Complete Corn 500, Avicta Duo Corn, Avicta Duo 250 Corn, Avicta Duo Cotton, Avicta Duo COT202, Besiege, Bicep II Magnum, Bicep II Magnum FC, Bicep Lite II Magnum, Callisto Xtra, Cyclone SL 2.0, Denim, Endigo ZC, Endigo ZCX, Epi-Mek 0.15EC, Expert, Force, Force 3G, Force CS, Force Evo, Force 6.5G, Gramoxone SL, Gramoxone SL 2.0, Gramoxone SL 3.0, Karate with Zeon Technology, Lamcap, Lamcap II, Lamdec, Lexar, Lexar EZ, Lumax, Lumax EZ, Medal II ATZ, Minecto Pro, Proclaim, Tavium Plus VaporGrip Technology, Voliam Xpress and Warrior II with Zeon Technology are Restricted Use Pesticides.", attributes: [.font: UIFont.boldSystemFont(ofSize: 6.0)]))
        
        document.add(space: 10.0)
        document.add(attributedText: NSMutableAttributedString().normal("Some seed treatment offers are separately registered products applied to the seed as a combined slurry.").bold(" Always read individual product labels and treater instructions before combining and applying component products.").normal(" Orondis Gold may be sold as a formulated premix or as a combination of separately registered products: Orondis Gold 200 and Orondis Gold B."))
        
        document.add(space: 10.0)
        document.add(attributedText: NSMutableAttributedString().bold("Important: Always read and follow label and bag tag instructions; only those labeled as tolerant to glufosinate may be sprayed with glufosinate ammonium-based herbicides.").normal(" LibertyLink®, Liberty® and the Water Droplet logo are registered trademarks of BASF. GT27™ is a trademark of M.S. Technologies and BASF. HERCULEX® and the HERCULEX Shield are trademarks of Dow AgroSciences, LLC. HERCULEX Insect Protection technology by Dow AgroSciences.").bold("Under federal and local laws, only dicamba-containing herbicides registered for use on dicamba-tolerant varieties may be applied. See product labels for details and tank mix partners.").normal("Golden Harvest® and NK® Soybean varieties are protected under granted or pending U.S. variety patents and other intellectual property rights, regardless of the trait(s) within the seed. The Roundup Ready 2 Yield® and Roundup Ready 2 Xtend® traits may be protected under numerous United States patents. It is unlawful to save soybeans containing these protected traits for planting or transfer to others for use as a planting seed. Only dicamba formulations that employ VaporGrip® Technology are approved for use with Roundup Ready 2 Xtend® soybeans. Only 2,4-D choline formulations with Colex-D® Technology are approved for use with Enlist E3® soybeans. Roundup Ready 2 Yield®, Roundup Ready 2 Xtend® and VaporGrip® and YieldGard VT Pro® are trademarks of, and used under license from, Monsanto Technology LLC. ENLIST E3® soybean technology is jointly developed with Dow AgroScience LLC and MS Technologies LLC. The ENLIST trait and ENLIST Weed Control System are technologies owned and developed by Dow Agrosciences LLC. ENLIST® and ENLIST E3® are trademarks of Dow AgroSciences LLC. The trademarks or service marks displayed or otherwise used herein are the property of a Syngenta Group Company.  All other trademarks are the property of their respective owners. More information about Agrisure Duracade® is available at http://www.biotradestatus.com/"))
        document.add(space: 15.0)
        document.addLineSeparator(style: PDFLineStyle(type: .full, color: UIColor(red: 0 / 255, green: 107 / 255, blue: 72 / 255, alpha: 1.0), width: 3.0))
        document.add(space: 5.0)
        let endImage = UIImage(named: "Syngenta_Circle_R_RGB") ?? UIImage()
        let endImagePDF = PDFImage(image: endImage)
        endImagePDF.sizeFit = .widthHeight
        endImagePDF.size = .init(width: 100, height: 22.0)
        document.add(.contentRight, image: endImagePDF)
        
        // Generate PDF
        
        do {
            // Generate PDF file and save it in a temporary file. This returns the file URL to the temporary file
            let filename = "\(growerFound.farmName) - \(planFound.displayName) - \(documentType.documentName).pdf".replacingOccurrences(of: "/", with: "")
            let pdfGenerator = PDFGenerator(document: document)
            let url = try pdfGenerator.generateURL(filename: filename)
            return url
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
        return nil
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 6.0)]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 6.0)]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        
        return self
    }
}

enum DocumentType {
    
    case estimate, cropPlan
    
    var documentName: String {
        switch self {
        case .estimate:
            return "Estimate"
        case .cropPlan:
            return "Crop Plan"
        }
    }
    
}
