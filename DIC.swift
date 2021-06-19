
import Foundation

typealias FactoryClosure = (DIC) -> AnyObject

// MARK: - Protocols

protocol DICProtocol: HasServiceOneProtocol, HasServiceTwoProtocol {
    func register<Service>(type: Service.Type, factoryClosure: @escaping FactoryClosure)
    func resolve<Service>(type: Service.Type) -> Service?
    func resolve<Service: Configurable>(type: Service.Type, configuration: Service.Configuration) -> Service?
}

protocol Configurable {
    associatedtype Configuration
    func configure(configuration: Configuration)
}

protocol ServiceOneProtocol {
    func getValue() -> Int
}

protocol ServiceTwoProtocol {
    func getValue() -> Int
}

protocol ServiceThreeProtocol {
    func getValue() -> Int
}

protocol HasServiceOneProtocol {
    var serviceOne: ServiceOneProtocol { get }
}

protocol HasServiceTwoProtocol {
    var serviceTwo: ServiceTwoProtocol { get }
}

// MARK: - Classes

class DIC: DICProtocol {
    var services = Dictionary<String, FactoryClosure>()
    
    func register<Service>(type: Service.Type, factoryClosure: @escaping FactoryClosure) {
        services["\(type)"] = factoryClosure
    }
    
    func resolve<Service>(type: Service.Type) -> Service? {
        return services["\(type)"]?(self) as? Service
    }
    
    func resolve<Service: Configurable>(type: Service.Type, configuration: Service.Configuration) -> Service? {
        let service = resolve(type: type)
        service?.configure(configuration: configuration)
        return service
    }
    
    var serviceOne: ServiceOneProtocol {
        resolve(type: ServiceOneProtocol.self)!
    }
    
    var serviceTwo: ServiceTwoProtocol {
        resolve(type: ServiceTwoProtocol.self)!
    }
}


class ServiceOne: ServiceOneProtocol {
    let serviceTwo: ServiceTwoProtocol
    
    init(serviceTwo: ServiceTwoProtocol) {
        self.serviceTwo = serviceTwo
    }
    
    convenience init(dic: DICProtocol) {
        self.init(serviceTwo: dic.resolve(type: ServiceTwoProtocol.self)!)
    }
    
    func getValue() -> Int {
        return 5 + serviceTwo.getValue()
    }
}

class ServiceTwo: ServiceTwoProtocol {
    init() {
        
    }
    func getValue() -> Int {
        return 7
    }
}

class ServiceThree: ServiceThreeProtocol, Configurable {
    
    struct ServiceThreeConfiguration {
        var paramOne: Int
        var paramTwo: Int
    }
    
    let serviceOne: ServiceOneProtocol
    var paramOne: Int!
    var paramTwo: Int!
    
    init(serviceOne: ServiceOneProtocol) {
        self.serviceOne = serviceOne
    }
    
    func configure(configuration: ServiceThreeConfiguration) {
        self.paramOne = configuration.paramOne
        self.paramTwo = configuration.paramTwo
    }
    
    func getValue() -> Int {
        return 0
    }
}

class ProtocolOrientedParent {
    typealias Dependencies = HasServiceOneProtocol & HasServiceTwoProtocol
    
    let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    convenience init(dic: DICProtocol) {
        self.init(dependencies: dic)
    }
}



// MARK: - Functions

func createDIC() -> DICProtocol {
    let dic = DIC()
    dic.register(type: ServiceOneProtocol.self) { dic in
        return ServiceOne(serviceTwo: dic.resolve(type: ServiceTwoProtocol.self)!)
    }
    dic.register(type: ServiceTwoProtocol.self) { dic in
        return ServiceTwo()
    }
    dic.register(type: ServiceThree.self) { dic in
        return ServiceThree(serviceOne: dic.resolve(type: ServiceOneProtocol.self)!)
    } // Must be class, not protocol, because we use parameters and configuration that is relative to the class
    return DIC()
}

func createServiceThree(dic: DICProtocol) -> ServiceThree {
    let configuration = ServiceThree.ServiceThreeConfiguration(paramOne: 2, paramTwo: 3)
    let serviceThree = dic.resolve(type: ServiceThree.self, configuration: configuration)
    return serviceThree!
}
