# swift-CCGenerator

Made for my programming and swift package managing skills practice and education purposes only. I'm not making responsible of any bad use of this code in any project. Programmed in Spanish.

The main code is located at Sources / CCGenerator / [CCGenerator](https://github.com/AOx0/swift-CCGenerator/tree/master/Sources/CCGenerator/CCGenerator.swift) 



## Usage

1. First set any custom configurations accessing to the indexed classes in `Generator.Configuracion`. More info at **[Configuration](https://github.com/AOx0/swift-CCGenerator#CCGenerator)**
2. Use the `Generador.generarCC(bin: String)` method. It returns a CC object which has various methods to print itself in various formats.



Example:

```swift
import CCGenerator

//Configuration
Generador.Configuracion.Año.valor = "2024"
Generador.Configuracion.LongitudDeCC.tamaño = 19

//Main
print(Generador.generarCC(bin: "123456").formatoChecker()) //1234564051139615830|06|2024|693

```



## Configuration

Available configurations:

1. `Generador.Configuracion.Año.valor` **: String** - Custom Year for the CC - `Default: Random (nil) `
2. `Generador.Configuracion.Mes.valor` **: String** - Custom Month for the CC - `Default: Random (nil) `
3. `Generador.Configuracion.CVV.valor` **: String** - Custom CVV for the CC -  `Default: Random (nil) `
4. `Generador.Configuracion.LongitudDeCC.tamaño` **: Int** - Custom CC lenght [12 to 19] -  `Default: 16 `
5. `Generador.Configuracion.LongitudDeCC.autoCorregirLongitud` **: Bool** - Autorrects the Bin's lenght if its disabled - `Default: false `



## Generated CC output formats:

- Checker `1234566978725253|09|2023|527`
- CSV `1234566978725253, 527, 09/2023 `
- JSON (single result) 
- XML (single result) 