//
//  ContentView.swift
//  Simple Damage Calc
//
//  Created by Jesse Joseph on 30/09/21.
//

import SwiftUI

struct CalculatorView:View{
    @State private var baseAttack:String = "1000"
    @State private var bonusAttackPercent:String = "0"
    @State private var bonusAttackFlat:String = "0"
    @State private var totalAtk:Int = 0
    
    @State private var conversionRate:String = "0"
    @State private var conversionSource:String = "0"
    @State private var conversionTotal:Int = 0
    @State private var shouldConversion:Bool = false
    
    @Environment (\.presentationMode) var presentationMode
    
    var body: some View{
        Form{
            Section(header:Text("Calculation")){
                VStack(alignment:.leading){
                    HStack{
                        Text("Base Attack: ")
                        TextField(self.baseAttack, text: $baseAttack)
                            .keyboardType(.decimalPad)
                            .onChange(of: self.baseAttack, perform: { _ in
                                self.calculateTotalAtk()
                            })
                    }
                    Text("Base attack is the white number on the attributes section on Attack stat")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }.padding(.vertical)
                
                VStack(alignment:.leading){
                    HStack{
                        Text("%Atk Bonus: ")
                        TextField(self.bonusAttackPercent, text: $bonusAttackPercent)
                            .keyboardType(.decimalPad)
                            .onChange(of: self.bonusAttackPercent, perform: { _ in
                                self.calculateTotalAtk()
                            })
                    }
                    Text("Total up all +atk% stats, main and substats")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }.padding(.vertical)
                
                VStack(alignment:.leading){
                    HStack{
                        Text("Flat Atk Bonus: ")
                        TextField(self.bonusAttackFlat, text: $bonusAttackFlat)
                            .keyboardType(.decimalPad)
                            .onChange(of: self.bonusAttackFlat, perform: { _ in
                                self.calculateTotalAtk()
                            })
                    }
                    Text("Total up all +atk stats, main stats from plume and substats")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }.padding(.vertical)
            }
            
            Section(header:Text("Attack Conversion")){
                Toggle(isOn: self.$shouldConversion) {
                    Text("Does your attack increase from a conversion from other stats?")
                }
                .padding(.vertical)
                    
                if self.shouldConversion{
                    HStack{
                        Text("Conversion Rate(%): ")
                        TextField(self.conversionRate, text: self.$conversionRate)
                            .keyboardType(.decimalPad)
                            .onChange(of: self.conversionRate, perform: { _ in
                                self.calculateTotalAtk()
                            })
                    }
                    
                    HStack{
                        Text("Conversion Source: ")
                        TextField(self.conversionSource, text: $conversionSource)
                            .keyboardType(.decimalPad)
                            .onChange(of: self.conversionSource, perform: { _ in
                                self.calculateTotalAtk()
                            })
                    }
                    
                    Text("Conversion Total: \(conversionTotal)")
                }
                
            }
            
            Section(header:Text("Total After Calculation")){
                Text("Total Attack: \(totalAtk)")
            }
        
            Button {
                self.copyAndDismiss()
            } label: {
                Text("Copy Total Attack and Dismiss")
            }

        }
    }
    
    func calculateTotalAtk(){
        let baseAtkValue:Float = Float(self.baseAttack) ?? 0
        let flatAtkValue:Float = Float(self.bonusAttackFlat) ?? 0
        let percentAtkValue:Float = Float(self.bonusAttackPercent) ?? 0
        let conversionRateValue:Float = Float(self.conversionRate) ?? 0
        let conversionSourceValue:Float = Float(self.conversionSource) ?? 0
        
        let conversionValue = (conversionRateValue / 100) * conversionSourceValue
        self.conversionTotal = Int(conversionValue)
        
        let totalAtkValue = (baseAtkValue * ((100 + percentAtkValue) / 100)) + flatAtkValue + conversionValue
        self.totalAtk = Int(totalAtkValue)
    }
    
    func copyAndDismiss(){
        UIPasteboard.general.string = String(self.totalAtk)
        self.presentationMode.wrappedValue.dismiss()
    }
}

struct ContentView: View {
    enum elements:String, CaseIterable{
        case none = "None"
        case pyro = "Pyro"
        case cryo = "Cryo"
        case electro = "Electro"
        case anemo = "Anemo"
        case hydro = "Hydro"
        case geo = "Geo"
        
        var possibleReactions:[reactions]{
            switch self {
            case .pyro:
                return [.vape,.melt,.shatter]
            case .cryo:
                return [.melt,.shatter]
            case .hydro:
                return [.vape,.shatter]
            case .anemo:
                return [.swirl,.shatter]
            case .electro:
                return [.elecCharge, .overload,.shatter]
            case .geo:
                return [.shatter]
            default:
                return []
            }
        }
    }
    
    enum reactions:String, CaseIterable{
        //Amplify
        case vape = "Vaporize"
        case melt = "Melt"
        
        //Transformative
        case swirl = "Swirl"
        case elecCharge = "Electro Charged"
        case overload = "Overload"
        case shatter = "Shatter"
        //Etc.
        case none = "None"
        
        var isAmplifying:Bool{
            switch self {
            case .vape, .melt:
                return true
            case .elecCharge, .overload, .swirl, .shatter:
                return false
            default:
                return false
            }
        }
        
    }
    
    //Element
    @State private var element:elements = .none
    
    //Multipliers
    @State private var myLevel:String = "1"
    @State private var attack:String = "1000"
    @State private var multiplier:String = "300"
    @State private var cDamage:String = "50"
    @State private var cRate:String = "5"
    @State private var eDamageBonus:String = "0"
    
    //Enemy Stats
    @State private var enemyLevel:String = "1"
    @State private var resistance:String = "0"
    @State private var defShred:String = "0"
    
    //Reactions
    @State private var willReaction:Bool = false
    @State private var EMValue:String = "0"
    @State private var reaction:reactions = .none
    @State private var reactionBonus:String = "0"
    
    //Final Values
    @State private var rawCharaDamage:Int = 0{
        didSet{
            self.finalDamage = self.calculateTotalDamage()
            self.averageFinalDamage = self.calculateAverageTotalDamage()
        }
    }
    @State private var incomingDamage:Int = 0{
        didSet{
            self.finalDamage = self.calculateTotalDamage()
            self.averageFinalDamage = self.calculateAverageTotalDamage()
        }
    }
    @State private var enemyResMultiplier:Float = 0
    @State private var reactionMultiplier:Float = 0{
        didSet{
            self.finalDamage = self.calculateTotalDamage()
            self.averageFinalDamage = self.calculateAverageTotalDamage()
        }
    }
    
    @State private var averageDamage:Float = 0
    @State private var averageIncomingDamage:Float = 0
    @State private var finalDamage:Float = 0
    @State private var averageFinalDamage:Float = 0
    
    //Comparison Stuffs
    @Binding var compareDamage:Float
    @Binding var compareAvgDamage:Float
    @Environment (\.presentationMode) var presentationMode
    @State private var totalDifference:Float = 0
    @State private var averageDifference:Float = 0
    @State private var percentTotalDifference:Float = 0
    @State private var percentAverageDifference:Float = 0
    
    //Calculator Stuffs
    @State private var shouldShowCalculator:Bool = false
    
    @State private var shouldShowComparisonScreen:Bool = false
    
    var body: some View {
        NavigationView{
            Form{
                Section(header:Text("Element")){
                    Picker(selection: $element, label: Text("Element:"), content: {
                        ForEach(elements.allCases, id: \.self) { anElement in
                            Text(anElement.rawValue)
                        }
                    }).onReceive([self.element].publisher.first(), perform: { _ in
                        self.resetReactionValues()
                    })
                }
                
                if element != .none{
                    Section(header:Text("Basic Attributes")){
                        HStack{
                            Text("Chara Level:")
                            TextField(self.myLevel, text: $myLevel)
                            .keyboardType(.decimalPad)
                            .onChange(of: myLevel, perform: { _ in
                                self.calculateValue()
                            })
                        }
                        
                        VStack{
                            HStack{
                                Text("Attack Value:")
                                TextField(self.attack, text: $attack)
                                .keyboardType(.decimalPad)
                                .onChange(of: attack, perform: { _ in
                                    self.calculateValue()
                                })
                                
                                Spacer()
                                
                                Button {
                                    self.shouldShowCalculator = true
                                } label: {
                                    Text("Calc Atk")
                                }.sheet(isPresented: $shouldShowCalculator, content: {
                                    CalculatorView()
                                })

                            }
                            Text("This is the flat final attack value, add in attack buffs to the total if any is used")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment:.leading){
                            HStack{
                                Text("Multiplier(%):")
                                TextField(self.multiplier, text: $multiplier)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: multiplier, perform: { _ in
                                        self.calculateValue()
                                    })
                            }
                            Text("This is the movement value of the move, grabbed from talent")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack{
                            Text("C.Damage Value(%):")
                            TextField(self.cDamage, text: $cDamage)
                            .keyboardType(.decimalPad)
                            .onChange(of: cDamage, perform: { _ in
                                self.calculateValue()
                            })
                        }
                        
                        HStack{
                            Text("C.Rate Value(%):")
                            TextField(self.cRate, text: $cRate)
                                .keyboardType(.decimalPad)
                                .onChange(of: cRate, perform: { _ in
                                    self.calculateValue()
                                })
                        }
                        
                        VStack(alignment:.leading){
                            HStack{
                                Text("Damage Bonus(%):")
                                TextField(self.eDamageBonus, text: $eDamageBonus)
                                .keyboardType(.decimalPad)
                                    .onChange(of: eDamageBonus, perform: { _ in
                                        self.calculateValue()
                                    })
                            }
                            Text("Also includes any other buff that boosts damage%")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment:.leading){
                            Text("Raw Chara Damage: \(self.rawCharaDamage)")
                                .padding(.bottom, 4)
                            Text("Average Chara Damage: \(Int(self.averageDamage))")
                        }
                        .padding(.vertical)
                    }
                    
                    Section(header:Text("Enemy Status")){
                        HStack{
                            Text("Enemy Level:")
                            TextField(self.enemyLevel, text: $enemyLevel)
                            .keyboardType(.decimalPad)
                            .onChange(of: enemyLevel, perform: { _ in
                                self.calculateValue()
                            })
                        }
                        
                        VStack(alignment:.leading){
                            HStack{
                                Text("Resistance(%):")
                                TextField(self.resistance, text: $resistance)
                                    .keyboardType(.numbersAndPunctuation)
                                    .onChange(of: resistance, perform: { _ in
                                        self.calculateValue()
                                    })
                            }
                            Text("If you shred using viridescent set or any abilities, subtract it from the original resistance, then input the result instead")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack{
                            Text("Defense Shred(%):")
                            TextField(self.defShred, text: $defShred)
                                .keyboardType(.decimalPad)
                                .onChange(of: enemyLevel, perform: { _ in
                                    self.calculateValue()
                                })
                        }
                        
                        Text("Incoming Damage: \(self.incomingDamage)").padding(.vertical)
                    }
                    
                    if (element != .none){
                        Section(header:Text("Reactions")){
                            Toggle("Calculate Reactions?", isOn: $willReaction)
                            
                            if willReaction{
                                Picker(selection: $reaction, label: Text("Reaction:"), content: {
                                    ForEach(self.element.possibleReactions, id: \.self){ aReaction in
                                        Text(aReaction.rawValue)
                                    }
                                }).onReceive([self.reaction].publisher.first(), perform: { _ in
                                    self.calculateValue()
                                })
                                
                                HStack{
                                    Text("Elemental Mastery:")
                                    TextField(self.EMValue, text: $EMValue)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: EMValue, perform: { _ in
                                        self.calculateValue()
                                    })
                                }
                                
                                HStack{
                                    Text("Reaction Bonus(%):")
                                    TextField(self.reactionBonus, text: $reactionBonus)
                                        .keyboardType(.decimalPad)
                                        .onChange(of: EMValue, perform: { _ in
                                            self.calculateValue()
                                        })
                                }
            
                                if self.reaction.isAmplifying{
                                    Text("Reaction Multiplier: \(self.reactionMultiplier, specifier: "%.2f")").padding(.vertical)
                                }else{
                                    Text("\(self.reaction.rawValue) Damage: \(self.reactionMultiplier, specifier: "%.2f")").padding(.vertical)
                                }
                            }
                        }
                    }
                }
                
                if element != .none{
                    if self.reaction.isAmplifying{
                        Section(header:Text("Total Damage")){
                            VStack(alignment:.leading){
                                Text("Total Damage: \(Int(self.finalDamage))")
                                    .padding(.bottom, 4)
                                Text("Average Damage: \(Int(self.averageFinalDamage))")
                                Text("This damage might differ as this is just a simple calculator")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }.padding(.vertical)
                            
                        }
                    }else{
                        Section(header:Text("Total Damage")){
                            VStack(alignment:.leading){
                                Text("Total Damage: \(Int(self.incomingDamage))")
                                    .padding(.bottom, 4)
                                Text("Average Damage: \(Int(self.averageFinalDamage))")
                                Text("This damage might differ as this is just a simple calculator")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }.padding(.vertical)
                            
                        }

                    }
                }
                
                if self.element != .none && (self.compareDamage < 0 && self.compareAvgDamage < 0){
                    
                    Button("Compare with other stat", action: {
                        self.shouldShowComparisonScreen = true
                    }).sheet(isPresented: $shouldShowComparisonScreen, content: {
                        ContentView(compareDamage: $finalDamage, compareAvgDamage: $averageFinalDamage)
                    })
                    
                    
                }else if (self.compareDamage >= 0 && self.compareAvgDamage >= 0){
                    
                    
                    if self.element != .none{
                        Section(header:Text("Comparison")){
                            VStack(alignment:.leading){
                                VStack(alignment:.leading){
                                    Text("Total Damage Difference: \(self.totalDifference, specifier:"%.0f"), (\(self.percentTotalDifference, specifier: "%.0f"))% difference from first status")
                                    
                                    Text("Difference from \(self.compareDamage, specifier: "%.0f") to \(self.finalDamage, specifier: "%.0f")")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment:.leading){
                                    Text("Total Damage Difference: \(self.averageDifference, specifier:"%.0f"), (\(self.percentAverageDifference, specifier: "%.0f"))% difference from first status")
                                    
                                    Text("Difference from \(self.compareAvgDamage, specifier: "%.0f") to \(self.averageFinalDamage, specifier: "%.0f")")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Return")
                    }
                }
                
            }
            .navigationBarTitle("Simple Damage Calc")
            .onAppear(perform: {
                self.initValues()
            })
            .navigationBarItems(trailing: Button("Reset Values", action: {
                self.resetValues()
            }))
        }
    }
    
    func calculateValue(){
        self.calculateRawCharaDamage()
        self.calculateIncomingDamage()
        self.calculateReactionMultiplier()
        
        if self.compareDamage >= 0 && self.compareAvgDamage >= 0{
            self.calculateComparissonDamage()
        }
    }
    
    func calculateRawCharaDamage(){
        var outgoingDamage:Float = 0 // (ATK total * %Motion Value * (1 + %Damage Bonus)) * (1 + %C Damage)
        var avgOutgoingDamage:Float = 0
        
        let atkValue = Float(self.attack) ?? 0
        let multiplierValue = (Float(self.multiplier) ?? 0) / 100
        let cDamage = (Float(self.cDamage) ?? 0) / 100
        let cRate = (Float(self.cRate) ?? 0) / 100
        let eBonus = (Float(self.eDamageBonus) ?? 0) / 100
        
        outgoingDamage = (atkValue * multiplierValue * (1 + eBonus)) * (1 + cDamage)
        avgOutgoingDamage = (atkValue * multiplierValue * (1 + eBonus)) * (1 + (cRate * cDamage))
        
        self.averageDamage = avgOutgoingDamage
        self.rawCharaDamage = Int(outgoingDamage)
    }
    
    func calculateIncomingDamage(){
        var incomingDamage:Float = 0 //rawCharaDamage * defMulti * resMulti
        var avgIncomingDamage:Float = 0
        
        let levelValue = Float(self.myLevel) ?? 0
        let enemyLevelValue = Float (self.enemyLevel) ?? 0
        let enemyResValue = (Float (self.resistance) ?? 0) / 100
        let defShredValue = (Float (self.defShred) ?? 0) / 100
        
        let defMulti = (levelValue + 100)/(((1 - defShredValue) * (enemyLevelValue + 100)) + (levelValue + 100))
        var resMulti:Float = 0
        
        //Resistance Modifier
        if enemyResValue < 0{
            resMulti = 1 - (enemyResValue/2)
        }else if enemyResValue < 0.75{
            resMulti = 1 - enemyResValue
        }else{
            resMulti = 1/((4 * enemyResValue) + 1)
        }
        
        incomingDamage = Float(self.rawCharaDamage) * defMulti * resMulti
        avgIncomingDamage = self.averageDamage * defMulti * resMulti
        
        self.enemyResMultiplier = resMulti
        self.averageIncomingDamage = avgIncomingDamage
        self.incomingDamage = Int(incomingDamage)
        
    }
    
    func calculateReactionMultiplier(){
        if self.reaction != .none{
            let baseReactionMulti = returnBaseMulti(element: self.element, reaction: self.reaction)
            
            if self.reaction.isAmplifying{
                var reactionAmplifyValue:Float = 0 // baseReactionMulti * (1 + %EMAmpValue + %reactionBonus)
                
                let EMStatValue = (Float(self.EMValue) ?? 0)
                let EMAmpValue = 2.78 * ((EMStatValue)/(EMStatValue + 1400))
                let reactionBonusValue = (Float(self.reactionBonus) ?? 0) / 100
                reactionAmplifyValue = baseReactionMulti * (1 + EMAmpValue + reactionBonusValue)
                self.reactionMultiplier = reactionAmplifyValue
            }else{
                var transformativeDamage:Float = 0
                let charaLevelValue = (Float(self.myLevel) ?? 1)
                let EMValue = Int(self.EMValue) ?? 0 > 0 ? Float(self.EMValue) ?? 1 : 1
                
                let EMTransformative:Float = (16 * (EMValue / (EMValue + 2000)))/100
                let reactionBonusValue = (Float(self.reactionBonus) ?? 0) / 100
                transformativeDamage = baseReactionMulti * charaLevelValue * (1 + EMTransformative + reactionBonusValue)
                let incomingTransformative:Float = transformativeDamage * self.enemyResMultiplier
                self.reactionMultiplier = Float(incomingTransformative.rounded())
            }
        }
        
    }
    
    func calculateTotalDamage()->Float{
        if reactionMultiplier == 0{
            return Float(self.incomingDamage).rounded()
        }
        return (Float(self.incomingDamage) * self.reactionMultiplier).rounded()
    }
    
    func calculateAverageTotalDamage()->Float{
        if reactionMultiplier == 0{
            return Float(self.averageIncomingDamage).rounded()
        }
        return (Float(self.averageIncomingDamage) * self.reactionMultiplier).rounded()
    }
    
    func calculateComparissonDamage(){
        let averageTotalDiff:Float = self.averageFinalDamage - self.compareAvgDamage
        let totalDiff:Float = self.finalDamage - self.compareDamage
        self.averageDifference = averageTotalDiff
        self.totalDifference = totalDiff
        
        let perAverageTotalDiff:Float = (averageTotalDiff/self.compareAvgDamage) * 100
        let perTotalDiff:Float = (totalDiff/self.compareDamage) * 100
        self.percentTotalDifference = perTotalDiff
        self.percentAverageDifference = perAverageTotalDiff
    }
    
    func initValues(){
        self.calculateValue()
    }
    
    func returnBaseMulti(element:elements, reaction:reactions) -> Float{
        switch reaction{
        case .vape:
            if element == .pyro{
                return 1.5
            }else if element == .hydro{
                return 2
            }
        case .melt:
            if element == .cryo{
                return 1.5
            }else if element == .pyro{
                return 2
            }
        case .swirl:
            return 1.2
            
        case .elecCharge:
            return 2.4
            
        case .overload:
            return 4
            
        case .shatter:
            return 3
            
        default:
            return 0
        }
        return 0
    }
    
    func resetReactionValues(){
        if self.element == .none || self.element == .geo{
            self.willReaction = false
            self.EMValue = "0"
            self.reactionBonus = "0"
            self.reaction = .none
        }
    }
    
    func resetValues(){
        self.element = .none
        
        self.myLevel = "1"
        self.attack = "1000"
        self.multiplier = "300"
        self.cDamage = "50"
        self.cRate = "5"
        self.eDamageBonus = "0"
        
        self.enemyLevel = "1"
        self.resistance = "0"
        self.defShred = "0"
        
        self.willReaction = false
        self.EMValue = "0"
        self.reaction = .none
        self.reactionBonus = "0"
        
        self.initValues()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(compareDamage: Binding.constant(-1), compareAvgDamage: Binding.constant(-1))
        CalculatorView()
    }
}
