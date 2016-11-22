//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Paul ReFalo on 10/19/16.
//  Copyright © 2016 QSS. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
