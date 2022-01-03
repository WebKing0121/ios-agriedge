//
//  RebateCalculatorTest.swift
//  AgriEdgeCalculatorToolTests
//
//  Created by GitLab Runner on 10/15/19.
//  Copyright © 2019 Syngenta. All rights reserved.
//

import XCTest
@testable import AgriEdgeCalculatorTool

class RebateCalculatorTest: XCTestCase {

    override func setUp() {
        super.setUp()
        PersistenceLayer().saveAll(of: RebateCalculatorTestData.testCrops)
        PersistenceLayer().saveAll(of: RebateCalculatorTestData.testProducts)
        PersistenceLayer().saveAll(of: RebateCalculatorTestData.testProductTriggers)
        PersistenceLayer().saveAll(of: RebateCalculatorTestData.testGrowers)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCalculatorCaseA() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (27279.63).currencyString()
        expectedRebate.estimatedRebateTotal = (492.0).currencyString()
        expectedRebate.estimatedSpend = (20002.5).currencyString()
        expectedRebate.fiftyFiftyTarget = (22733.02).currencyString()
        expectedRebate.tenNinetyCropsurance = (15082.50).currencyString()
        expectedRebate.estimatedSpendPerAcre = (20.00).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planOne, for: Grower(growerObject: RebateCalculatorTestData.growerOne))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
    
    func testCalculatorCaseB() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (106656.00).currencyString()
        expectedRebate.estimatedRebateTotal = (3600.2).currencyString()
        expectedRebate.estimatedSpend = (95002.00).currencyString()
        expectedRebate.fiftyFiftyTarget = (88880.00).currencyString()
        expectedRebate.tenNinetyCropsurance = (59000.00).currencyString()
        expectedRebate.estimatedSpendPerAcre = (95.00).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planTwo, for: Grower(growerObject: RebateCalculatorTestData.growerTwo))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
    
    func testCalculatorCaseC() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (57235.20).currencyString()
        expectedRebate.estimatedRebateTotal = (4769.60).currencyString()
        expectedRebate.estimatedSpend = (60000.00).currencyString()
        expectedRebate.fiftyFiftyTarget = (47696.00).currencyString()
        expectedRebate.tenNinetyCropsurance = (29810.00).currencyString()
        expectedRebate.estimatedSpendPerAcre = (60.00).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planThree, for: Grower(growerObject: RebateCalculatorTestData.growerThree))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
    
    func testCalculatorCaseD() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (111129.60).currencyString()
        expectedRebate.estimatedRebateTotal = (3912.00).currencyString()
        expectedRebate.estimatedSpend = (96999.98).currencyString()
        expectedRebate.fiftyFiftyTarget = (92608.00).currencyString()
        expectedRebate.tenNinetyCropsurance = (57880.00).currencyString()
        expectedRebate.estimatedSpendPerAcre = (48.50).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planFour, for: Grower(growerObject: RebateCalculatorTestData.growerFour))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
    
    func testCalculatorCaseE() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (59980.80).currencyString()
        expectedRebate.estimatedRebateTotal = (200.0).currencyString()
        expectedRebate.estimatedSpend = (33240.0).currencyString()
        expectedRebate.fiftyFiftyTarget = (49984.00).currencyString()
        expectedRebate.tenNinetyCropsurance = (31240.00).currencyString()
        expectedRebate.estimatedSpendPerAcre = (16.62).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planFive, for: Grower(growerObject: RebateCalculatorTestData.growerFive))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
    
    func testCalculatorCaseF() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (284160.00).currencyString()
        expectedRebate.estimatedRebateTotal = (0.0).currencyString()
        expectedRebate.estimatedSpend = (47373.73).currencyString()
        expectedRebate.fiftyFiftyTarget = (236800.00).currencyString()
        expectedRebate.tenNinetyCropsurance = (148000.0).currencyString()
        expectedRebate.estimatedSpendPerAcre = (23.69).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planSix, for: Grower(growerObject: RebateCalculatorTestData.growerSix))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
    
    func testCalculatorCaseG() {
        var expectedRebate = Rebate()
        expectedRebate.capRiskManagement = (116912.73).currencyString()
        expectedRebate.estimatedRebateTotal = (3609.39).currencyString()
        expectedRebate.estimatedSpend = (97003.00).currencyString()
        expectedRebate.fiftyFiftyTarget = (95490.91).currencyString()
        expectedRebate.tenNinetyCropsurance = (60909.09).currencyString()
        expectedRebate.estimatedSpendPerAcre = (48.50).currencyString()
        let calculatedRebate = RebateCalculator().calculateRebate(from: RebateCalculatorTestData.planSeven, for: Grower(growerObject: RebateCalculatorTestData.growerSeven))
        XCTAssertEqual(expectedRebate.capRiskManagement, calculatedRebate.capRiskManagement)
        XCTAssertEqual(expectedRebate.estimatedRebateTotal, calculatedRebate.estimatedRebateTotal)
        XCTAssertEqual(expectedRebate.estimatedSpend, calculatedRebate.estimatedSpend)
        XCTAssertEqual(expectedRebate.fiftyFiftyTarget, calculatedRebate.fiftyFiftyTarget)
        XCTAssertEqual(expectedRebate.tenNinetyCropsurance, calculatedRebate.tenNinetyCropsurance)
        XCTAssertEqual(expectedRebate.estimatedSpendPerAcre, calculatedRebate.estimatedSpendPerAcre)
    }
}
