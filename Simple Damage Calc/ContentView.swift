//
//  ContentView.swift
//  Simple Damage Calc
//
//  Created by Jesse Joseph on 30/09/21.
//

import SwiftUI

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
        }
    }
    @State private var incomingDamage:Int = 0{
        didSet{
            self.finalDamage = self.calculateTotalDamage()
        }
    }
    @State private var enemyResMultiplier:Float = 0
    @State private var reactionMultiplier:Float = 0{
        didSet{
            self.finalDamage = self.calculateTotalDamage()
        }
    }
    
    @State private var averageDamage:Float = 0
    
    @State private var finalDamage:Float = 0
    @State private var averageFinalDamage:Float = 0
    
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
                            TextField(self.cRate, text: $cRate) { _ in
                                self.calculateRawCharaDamage()
                            }
                            .keyboardType(.decimalPad)
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
    }
    
    func calculateRawCharaDamage(){
        var outgoingDamage:Float = 0 // (ATK total * %Motion Value * (1 + %Damage Bonus)) * (1 + %C Damage)
        
        let atkValue = Float(self.attack) ?? 0
        let multiplierValue = (Float(self.multiplier) ?? 0) / 100
        let cDamage = (Float(self.cDamage) ?? 0) / 100
        let cRate = (Float(self.cRate) ?? 0) / 100
        let eBonus = (Float(self.eDamageBonus) ?? 0) / 100
        
        outgoingDamage = (atkValue * multiplierValue * (1 + eBonus)) * (1 + (cRate * cDamage))
        
        self.rawCharaDamage = Int(outgoingDamage)
    }
    
    func calculateIncomingDamage(){
        var incomingDamage:Float = 0 //rawCharaDamage * defMulti * resMulti
        
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
        
        self.enemyResMultiplier = resMulti
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
        ContentView()
    }
}
