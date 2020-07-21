//
//  Generador.swift
//  swift-ccg2
//
//  Created by Alejandro D on 18/07/20.
//  Copyright © 2020 Alejandro D. All rights reserved.
//

import Foundation

//MARK: - Tarjeta De Crédito

fileprivate struct NumeroIdentificacion {
    var digitos : String?
    
    func esValidoLuhn(number: String) -> Bool {
        return number.reversed().enumerated().map({
            let digit = Int(String($0.element))!
            let even = $0.offset % 2 == 0
            return even ? digit : digit == 9 ? 9 : digit * 2 % 9
        }).reduce(0, +) % 10 == 0
    }
    
    
    fileprivate init(bin : String? = nil) {
        guard bin != nil else { return }
        let preCC = generarDigitosRandom(bin!)
        self.digitos = preCC+generarUltimoDigito(preCC)
    }
    
    private func generarUltimoDigito(_ bin : String) -> String {
        var caracterValido = ""
        for i in 0...9 {
            if esValidoLuhn(number: "\(bin)\(i)") {
                caracterValido = String(i)
                break
            }
        }
        return caracterValido
    }
    
    private func generarDigitosRandom(_ bin : String) -> String {
        var random = ""
        for i in 0...( bin.count - 2 ){
            if Int(String(Array(bin)[i])) == nil {
                random = random + String((Int.random(in: 0...9)))
            } else if Int(String(Array(bin)[i])) != nil {
                random = random + String(Array(bin)[i])
            }
            
        }
        return random
    }
}

fileprivate struct Fecha {
    var mes : String?
    var año : String?
}

fileprivate struct Codigo {
    var digitos : String?
}

public struct CC {
    fileprivate var digitos = NumeroIdentificacion()
    fileprivate var fecha = Fecha()
    fileprivate var cvv = Codigo()
    
    fileprivate var bin : String = ""
    fileprivate var longitudDeCC = 16
    
    //Formateo
    fileprivate var digitosDeTarjeta = ""
    fileprivate var mes = ""
    fileprivate var año = ""
    fileprivate var codigo =  ""
    
    
    func formatoChecker() -> String {
        return "\(digitosDeTarjeta)|\(mes)|\(año)|\(codigo)"
    }
    
    func formatoCSV() -> String {
        return "\(digitosDeTarjeta),\(codigo),\(mes)/\(año)"
    }
    
    func formatoXML() -> String {
        return String(
            "<xml>\n" +
            "<CreditCard>\n" +
            "<CardNumber>\(digitosDeTarjeta)</CardNumber>\n" +
            "<CardCCV2>\(codigo)</CardCCV2>\n" +
            "<CardExpDate>\(mes)/\(año)/CardExpDate>\n" +
            "</CreditCard>\n" +
            "</xml>"
        )
    }
    
    func formatoJSON() -> String {
        return String(
            "{\n" +
            "\"CreditCard\":{\n" +
            "\"CardNumber\": \"\(digitosDeTarjeta)\"\n" +
            "\"CardCCV2\": \"\(codigo)\"\n" +
            "\"CardExpDate\": \"\(mes)/\(año)\"\n" +
            "}\n" +
            "},"
        )
    }
    
    fileprivate init(bin: String) {
        self.bin = bin
        
        self.fecha.mes = Generador.generarMes()
        self.mes = String(self.fecha.mes!)
        
        self.fecha.año = Generador.generarAño()
        self.año = String(self.fecha.año!)
        
        self.cvv.digitos = Generador.generarCVV(self)
        self.codigo = String(self.cvv.digitos!)
        
        Generador.Configuracion.LongitudDeCC.tamaño = asignarLongitudDeCC()
        self.bin = arreglarBin(bin: self.bin)
        
        self.digitos = Generador.generarDigitos(bin: self.bin)
        self.digitosDeTarjeta = String(self.digitos.digitos!)
        
        if self.codigo.count == 4 {
            Generador.Configuracion.LongitudDeCC.autoCorregirLongitud.toggle()
        }
        
    }
    
    private func asignarLongitudDeCC() -> Int {
        switch Generador.Configuracion.LongitudDeCC.lenght{
        case .random: return 16
        case .personalizado(let longitudPersonalizada):
            if self.codigo.count == 4 {
                Generador.Configuracion.LongitudDeCC.tamaño = 15
                Generador.Configuracion.LongitudDeCC.autoCorregirLongitud = false
                return 15
            }
            return longitudPersonalizada
        }
    }
    
    private mutating func arreglarBin(bin : String) -> String {
        var bin = bin
        let cantidadDeNumericos : Int = contarNumerosEnBin(self.bin)
        let cantidadDeNoNumericos : Int = contarLetrasEnBin(self.bin)
        
        let tamañoDeBin = cantidadDeNumericos + cantidadDeNoNumericos
        let configuracionLongitud = Generador.Configuracion.LongitudDeCC.self
        
        if tamañoDeBin<configuracionLongitud.lenght.get(){
            if configuracionLongitud.autoCorregirLongitud {
                asignarLargoDeAcuerdoAlBin(tamañoDeBin)
            } else {
                colocaXFaltantes(&bin, tamañoDeseado: configuracionLongitud.lenght.get(), tamañoActual: tamañoDeBin)
            }
        } else {
            if configuracionLongitud.autoCorregirLongitud {
                asignarLargoDeAcuerdoAlBin(tamañoDeBin)
            } else {
                quitarXSobrantes(&bin, tamañoDeseado: configuracionLongitud.lenght.get(), tamañoActual: tamañoDeBin)
            }
        }
        
        return bin
    }
    
    private func quitarXSobrantes(_ bin : inout String, tamañoDeseado: Int, tamañoActual : Int) {
        for _ in 0..<tamañoActual - tamañoDeseado {
            bin.removeLast()
        }
    }
    
    private func colocaXFaltantes(_ bin : inout String, tamañoDeseado: Int, tamañoActual : Int) {
        for _ in 0..<tamañoDeseado - tamañoActual {
            bin += "x"
        }
    }
    
    private func asignarLargoDeAcuerdoAlBin(_ tamañoDeBin : Int) {
        guard tamañoDeBin > 11 && tamañoDeBin < 20 else { return }
        Generador.Configuracion.LongitudDeCC.tamaño = tamañoDeBin
    }
    
    private func contarNumerosEnBin(_ bin : String) -> Int {
        var numericos = 0
        for caracter in bin {
            if Int(String(caracter)) != nil { numericos += 1 }
            
        }
        return numericos
    }
    
    private func contarLetrasEnBin(_ bin : String) -> Int {
        var noNumericos = 0
        for caracter in bin {
            if Int(String(caracter)) == nil { noNumericos += 1 }
        }
        return noNumericos
    }
    
}

//MARK: - Generador

public struct Generador {
    private init() { return }
}

extension Generador {
    
    public static func generarCC(bin: String) -> CC {
        return CC(bin: bin)
    }
    
    fileprivate static func generarDigitos(bin: String) -> NumeroIdentificacion {
        return NumeroIdentificacion(bin: bin)
    }
    
    fileprivate static func generarMes() -> String {
        switch Generador.Configuracion.Mes.value {
        case .random : return impGenerarMes()
        case .personalizado(let mesPersonalizado) : return mesPersonalizado
        }
    }
    
    fileprivate static func generarAño() -> String {
        switch Generador.Configuracion.Año.value {
        case .random : return impGenerarAño()
        case .personalizado(let añoPersonalizado) : return añoPersonalizado
        }
    }
    
    fileprivate static func generarCVV(_ cc : CC) -> String {
        let longitud = asignarLongitudDeCVV(cc.bin)
        let cvvRandom = impGenerarCVV(longitud: longitud)
        
        switch Generador.Configuracion.CVV.value {
        case .random : return cvvRandom
        case .personalizado(let cvvPersonalizado):
            let bin = Int(String(cc.bin[String.Index(utf16Offset: 0, in: cc.bin)]))
            if bin == 3 && cvvPersonalizado.count != 4 { return cvvRandom }
            
            return cvvPersonalizado
        }
    }
    
    
    private static func impGenerarMes() -> String {
        let mes = Int.random(in: 1...12)
        if mes < 10 { return "0\(mes)" }
        
        return "\(mes)"
        
    }
    
    private static func impGenerarAño() -> String {
        let añoActual = Int(Calendar.current.component(.year, from: Date()))
        let añosDeVigencia = Int.random(in: 1...3)
        
        return "\(añoActual + añosDeVigencia)"
    }
    
    private static func impGenerarCVV(longitud: Int) -> String {
        var resultado = ""
        for _ in 0..<longitud {
            resultado += String(Int.random(in: 0...9)) }
        return resultado
    }
    
    
    private static func asignarLongitudDeCVV(_ bin : String ) -> Int {
        let bin = Int(String(bin[String.Index(utf16Offset: 0, in: bin)]))
        if bin == 3 { return 4 }
        return 3
    }
}


//MARK: - Generador.Configuración

extension Generador {
    struct Configuracion {
        private init() { return }
    }
}

fileprivate enum Valor{
    case personalizado(_ : String)
    case random
    
}

fileprivate enum ValorTamaño {
    case personalizado(_ : Int)
    case random
    
    func get() -> Int {
        switch self {
        case.personalizado(let valor): return valor
        case .random: return 16
        }
    }
}

fileprivate func resetValor<T>(_ valor : inout T?) {
    valor = nil
    print("Error: Reiniciando estado")
}


extension Generador.Configuracion {
    
    public class Mes {
        fileprivate static var value : Valor = .random
        static var valor : String? {
            didSet {
                if valor != nil {} else { resetValor(&valor);return }
                self.value = Valor.personalizado(self.valor!)
            }
        }
        private init() { return }
    }
}

extension Generador.Configuracion {
    
    public class Año {
        fileprivate static var value : Valor = .random
        static var valor : String? {
            didSet {
                if valor != nil {} else { resetValor(&valor);return }
                self.value = Valor.personalizado(self.valor!)
            }
        }
        private init() { return }
    }
}

extension Generador.Configuracion {
    
    public class CVV {
        fileprivate static var value : Valor = .random
        static var valor : String? {
            didSet {
                if valor != nil {} else { resetValor(&valor);return }
                self.value = Valor.personalizado(self.valor!)
            }
        }
        private init() { return }
    }
}

extension Generador.Configuracion {
    
    public class LongitudDeCC {
        public static var autoCorregirLongitud = false
        fileprivate static var lenght :  ValorTamaño = .random
        static var tamaño : Int? {
            didSet {
                guard tamaño != nil else { return }
                if (tamaño! > 11 && tamaño! < 20) {} else { resetValor(&tamaño);return }
                self.lenght = ValorTamaño.personalizado(self.tamaño!)
            }
        }
        private init() { return }
    }
}
