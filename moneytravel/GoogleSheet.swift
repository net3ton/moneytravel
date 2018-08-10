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

enum EGoogleSheetAlign: String {
    case center = "CENTER"
    case left = "LEFT"
    case right = "RIGHT"
}

enum EGoogleSheetBorder {
    case dashed
    case solid
}

func gs_column_letter(_ index: Int) -> String {
    let code = UnicodeScalar(65 + index % 26)!
    return String(code)
}

func gs_cell_address(column: Int, row: Int) -> String {
    return String(format: "%@%i", gs_column_letter(column), row)
}

class GoogleSheet {
    private var cells = GTLRSheets_UpdateCellsRequest()
    private var columnsCount = 0

    private var backColor: GTLRSheets_Color!

    private var numFormat: GTLRSheets_NumberFormat!
    private var dateFormat: GTLRSheets_NumberFormat!
    private var timeFormat: GTLRSheets_NumberFormat!

    private var dashedBorder: GTLRSheets_Border!
    private var solidBorder: GTLRSheets_Border!
    
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

        dashedBorder = GTLRSheets_Border()
        dashedBorder.style = "DASHED"
        dashedBorder.width = 1
        dashedBorder.color = makeColor(UIColor.black)

        solidBorder = GTLRSheets_Border()
        solidBorder.style = "SOLID"
        solidBorder.width = 1
        solidBorder.color = makeColor(UIColor.black)
        
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
    
    public func addString(_ value: String, align: EGoogleSheetAlign? = nil) {
        addValue(valString: value, valFormula: nil, align: align)
    }
    
    public func addFormula(_ value: String, align: EGoogleSheetAlign? = nil) {
        addValue(valString: nil, valFormula: value, align: align)
    }
    
    public func addEmpty( count: Int) {
        for _ in 0..<count {
            addString("")
        }
    }
    
    public func addValue(valString: String?, valFormula: String?, align: EGoogleSheetAlign? = nil) {
        let cellValue = GTLRSheets_ExtendedValue()
        cellValue.formulaValue = valFormula
        cellValue.stringValue = valString
        
        let cellFormat = GTLRSheets_CellFormat()
        cellFormat.backgroundColor = backColor
        
        if let align = align {
            cellFormat.horizontalAlignment = align.rawValue
        }
        
        let cellData = GTLRSheets_CellData()
        cellData.userEnteredFormat = cellFormat
        cellData.userEnteredValue = cellValue
        
        appendCell(cellData)
    }
    
    public func addFloat(_ value: Float) {
        addNumber(Double(value), format: numFormat)
    }
    
    public func addDate(_ value: Date) {
        addNumber(makeSerialDateFormat(value), format: dateFormat)
    }
    
    public func addTime(_ value: Date) {
        addNumber(makeSerialDateFormat(value), format: timeFormat)
    }
    
    public func addNumber(_ value: Double, format: GTLRSheets_NumberFormat, align: EGoogleSheetAlign? = nil) {
        let cellValue = GTLRSheets_ExtendedValue()
        cellValue.numberValue = value as NSNumber
        
        let cellFormat = GTLRSheets_CellFormat()
        cellFormat.backgroundColor = backColor
        cellFormat.numberFormat = format
        
        if let align = align {
            cellFormat.horizontalAlignment = align.rawValue
        }
        
        let cellData = GTLRSheets_CellData()
        cellData.userEnteredFormat = cellFormat
        cellData.userEnteredValue = cellValue
        
        appendCell(cellData)
    }

    private func getSheetBorder(top: EGoogleSheetBorder? = nil, bottom: EGoogleSheetBorder? = nil) -> GTLRSheets_Borders {
        let cellBorders = GTLRSheets_Borders()
        
        if top == .dashed {
            cellBorders.top = dashedBorder
        }
        else if top == .solid {
            cellBorders.top = solidBorder
        }
        
        if bottom == .dashed {
            cellBorders.bottom = dashedBorder
        }
        else if bottom == .solid {
            cellBorders.bottom = solidBorder
        }

        return cellBorders
    }
    
    public func setBorders(top: EGoogleSheetBorder? = nil, bottom: EGoogleSheetBorder? = nil) {
        cells.rows?.last?.values?.last?.userEnteredFormat?.borders = getSheetBorder(top: top, bottom: bottom)
    }
    
    public func setBordersAll(top: EGoogleSheetBorder? = nil, bottom: EGoogleSheetBorder? = nil) {
        let borders = getSheetBorder(top: top, bottom: bottom)
        
        for values in cells.rows!.last!.values! {
            values.userEnteredFormat?.borders = borders
        }
    }
    
    public func getCurrentRow() -> Int {
        return cells.rows!.count
    }

    public func getCurrentColumn() -> Int {
        return cells.rows!.last!.values!.count
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

    private func makeSerialDateFormat(_ val: Date) -> Double {
        var dateComponents = DateComponents()
        dateComponents.year = 1899
        dateComponents.month = 12
        dateComponents.day = 30

        let startDate = Calendar.current.date(from: dateComponents)
        let startTime = Calendar.current.startOfDay(for: val)

        let daysCount = Calendar.current.dateComponents([.day], from: startDate!, to: val).day!
        let secondsCount = Calendar.current.dateComponents([.second], from: startTime, to: val).second!

        return Double(daysCount) + Double(secondsCount) / (24 * 3600)
    }
}
