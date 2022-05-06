//
//  FlowFinisher.swift
//  Manuscript
//
//  Created by Tigran Ghazinyan on 5/6/22.
//

import Foundation

protocol FlowFinisher {
    func childDidFinish(child: Coordinator, flow: Flowable)
}
