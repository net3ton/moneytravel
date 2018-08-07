//
//  GoogleSheet.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 07/08/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class GoogleSheet {
    private var cells = GTLRSheets_UpdateCellsRequest()
    private var columnsCount = 0

    private var backColor: GTLRSheets_Color!
    private var numFormat: GTLRSheets_NumberFormat!
    private var dateFormat: GTLRSheets_NumberFormat!
    private var timeFormat: GTLRSheets_NumberFormat!
    
    init() {
        cells.range = GTLRSheets_GridRange()
        cells.rows = []
        cells.fields = "*"

        numFormat = GTLRSheets_NumberFormat()
        numFormat.type = "NUMBER"
        numFormat.pattern = "# ##0.00"

        dateFormat = GTLRSheets_NumberFormat()
        dateFormat.type = "DATE"
        dateFormat.pattern = "dd.MM.yyyy"

        timeFormat = GTLRSheets_NumberFormat()
        timeFormat.type = "DATE"
        timeFormat.pattern = "hh:mm"

        //dateFormat.pattern = "hh:mm:ss am/pm, ddd mmm dd yyyy"  // 02:05:07 PM, Sun Apr 03 2018
    }

    public func appendRow(bgcolor: UIColor) {
        backColor = makeColor(bgcolor)
        
        let row = GTLRSheets_RowData()
        row.values = []
        
        cells.rows?.append(row)
    }

    private func appendCell(_ data: GTLRSheets_CellData) {
        cells.rows?.last?.values?.append(data)
        columnsCount = max(columnsCount, cells.rows?.last?.values?.count ?? 0)
    }
    
    public func getUpdateCellsRequest() -> GTLRSheets_UpdateCellsRequest {
        cells.range?.startColumnIndex = 0
        cells.range?.endColumnIndex = columnsCount as NSNumber
        cells.range?.startRowIndex = 0
        cells.range?.endRowIndex = cells.rows!.count as NSNumber

        return cells
    }

    public func addString(_ value: String) {
        let cellValue = GTLRSheets_ExtendedValue()
        cellValue.stringValue = value
        
        let cellFormat = GTLRSheets_CellFormat()
        cellFormat.backgroundColor = backColor
        //cellFormat.horizontalAlignment = "CENTER"

        let cellData = GTLRSheets_CellData()
        cellData.userEnteredFormat = cellFormat
        cellData.userEnteredValue = cellValue

        appendCell(cellData)
    }
    
    public func addFloat(_ value: Float) {
        let cellValue = GTLRSheets_ExtendedValue()
        cellValue.numberValue = value as NSNumber

        let cellFormat = GTLRSheets_CellFormat()
        cellFormat.backgroundColor = backColor
        cellFormat.numberFormat = numFormat
        //cellFormat.horizontalAlignment = "CENTER"
        
        let cellData = GTLRSheets_CellData()
        cellData.userEnteredFormat = cellFormat
        cellData.userEnteredValue = cellValue
    
        appendCell(cellData)
    }
    
    public func addDate(_ value: Date) {
        /*
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        addString(dateFormatter.string(from: value))
        */

        let cellValue = GTLRSheets_ExtendedValue()
        cellValue.numberValue = value.timeIntervalSince1970 as NSNumber
        
        let cellFormat = GTLRSheets_CellFormat()
        cellFormat.backgroundColor = backColor
        cellFormat.numberFormat = dateFormat
        
        let cellData = GTLRSheets_CellData()
        cellData.userEnteredFormat = cellFormat
        cellData.userEnteredValue = cellValue
        
        appendCell(cellData)
    }
    
    public func addTime(_ value: Date) {
        /*
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        addString(timeFormatter.string(from: value))
        */

        let cellValue = GTLRSheets_ExtendedValue()
        cellValue.numberValue = value.timeIntervalSince1970 as NSNumber
        
        let cellFormat = GTLRSheets_CellFormat()
        cellFormat.backgroundColor = backColor
        cellFormat.numberFormat = timeFormat
        
        let cellData = GTLRSheets_CellData()
        cellData.userEnteredFormat = cellFormat
        cellData.userEnteredValue = cellValue
        
        appendCell(cellData)
    }
    
    private func makeColor(_ val: UIColor) -> GTLRSheets_Color {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a: CGFloat = 0
        val.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let color = GTLRSheets_Color()
        color.alpha = a as NSNumber
        color.red = r as NSNumber
        color.green = g as NSNumber
        color.blue = b as NSNumber
        return color
    }
    
}
