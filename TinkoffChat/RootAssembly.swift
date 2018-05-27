//
//  RootAssembly.swift
//  TinkoffChat
//
//  Created by Олег Самойлов on 21/04/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

class RootAssembly {
    lazy var presentationAssembly: IPresentationAssembly = PresentationAssembly(serviceAssembly: servicesAssembly)
    private lazy var servicesAssembly: IServicesAssembly = ServicesAssembly(coreAssembly: coreAssembly)
    private lazy var coreAssembly: ICoreAssembly = CoreAssembly()
}
