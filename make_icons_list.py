# -*- coding: utf-8 -*-
import os

ASSETS_FOLDER = "moneytravel/Assets.xcassets/Categories"
OUT_SWIFT_FILE = "moneytravel/Icons.swift"

HEADER = """//
//  Icons.swift
//  moneytravel
//
//  Created by Aleksandr Kharkov on 05/06/2018.
//  Copyright © 2018 Oleksandr Kharkov. All rights reserved.
//

import UIKit

let ICON_NAMES = [
"""

FOOTER = "]"

icon_names = []

for dirpath, dirnames, filenames in os.walk(ASSETS_FOLDER):
    for dname in dirnames:
        if dname.endswith(".imageset"):
            icon_names.append(os.path.splitext(dname)[0])

with open(OUT_SWIFT_FILE, "w") as fout:
    fout.write(HEADER)

    for iname in icon_names:
        fout.write("    \"" + iname + "\",\n")

    fout.write(FOOTER)
