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
                return [.vape,.melt]
            case .cryo:
                return [.melt]
            case .hydro:
                return [.vape]
//            case .anemo:
//                return [.swirl]
//            case .electro:
//                return [.elecCharged, .overload]
            default:
                return []
            }
        }
    }
    
    enum reactions:String, CaseIterable{
        case vape = "Vaporize"
        case melt = "Melt"
        case none = "None"
    }
    
    //Element
    @State private var element:elements = .none
    
    //Multipliers
    @State private var myLevel:String = "1"
    @State private var attack:String = "1000"
    @State private var multiplier:String = "300"
    @State private var cDamage:String = "50"
//    @State private var cRate:String = "5"
    @State private var eDamageBonus:String = "0"
    
    //Enemy Stats
    @State private var enemyLevel:String = "1"
    @State private var resistance:String = "0"
    
    //Reactions
    @State private var willReaction:Bool = false
    @State private var EMValue:String = "0"
    @State private var reaction:reactions = .none
    
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
    @State private var reactionMultiplier:Float = 0{
        didSet{
            self.finalDamage = self.calculateTotalDamage()
        }
    }
    
    @State private var finalDamage:Int = 0
    
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
                        
//                        HStack{
//                            Text("C.Rate Value(%):")
//                            TextField(self.cRate, text: $cRate) { _ in
//                                self.calculateRawCharaDamage()
//                            }
//                            .keyboardType(.decimalPad)
//                        }
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
                        
                        Text("Raw Chara Damage: \(self.rawCharaDamage)")
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
                                .keyboardType(.decimalPad)
                                    .onChange(of: resistance, perform: { _ in
                                        self.calculateValue()
                                    })
                            }
                            Text("If you shred using viridescent set or any abilities, subtract it from the original resistance, then input the result instead")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Incoming Damage: \(self.incomingDamage)").padding(.vertical)
                    }
                    
                    if element == .pyro || element == .cryo || element == .hydro{
                        Section(header:Text("Reactions")){
                            Toggle("Calculate Reactions?", isOn: $willReaction)
                            
                            if willReaction{
                                HStack{
                                    Text("Elemental Mastery:")
                                    TextField(self.EMValue, text: $EMValue)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: EMValue, perform: { _ in
                                        self.calculateReactionMultiplier()
                                    })
                                }
                                
                                Picker(selection: $reaction, label: Text("Reaction:"), content: {
                                    ForEach(self.element.possibleReactions, id: \.self){ aReaction in
                                        Text(aReaction.rawValue)
                                    }
                                }).onReceive([self.reaction].publisher.first(), perform: { _ in
                                    self.calculateValue()
                                })
                                
                                Text("Reaction Multiplier: \(self.reactionMultiplier)").padding(.vertical)
                                
                            }
                        }
                    }
                }
                
                if element != .none{
                    Section(header:Text("Total Damage")){
                        VStack(alignment:.leading){
                            Text("Total Damage: \(self.finalDamage)")
                            Text("This damage might differ as this is just a simple calculator")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }.padding(.vertical)
                        
                    }
                }
                
            }
            .navigationBarTitle("Simple Damage Calc")
            .onAppear(perform: {
                self.initValues()
            })
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
//        let cRate = Int (self.cRate)
        let eBonus = (Float(self.eDamageBonus) ?? 0) / 100
        
        outgoingDamage = (atkValue * multiplierValue * (1 + eBonus)) * (1 + cDamage)
        
        self.rawCharaDamage = Int(outgoingDamage)
    }
    
    func calculateIncomingDamage(){
        var incomingDamage:Float = 0 //rawCharaDamage * defMulti * resMulti
        
        let levelValue = Float(self.myLevel) ?? 0
        let enemyLevelValue = Float (self.enemyLevel) ?? 0
        let enemyResValue = (Float (self.resistance) ?? 0) / 100
        
        let defMulti = (levelValue + 100)/(levelValue + enemyLevelValue + 200)
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
        self.incomingDamage = Int(incomingDamage)
        
        //MARK: TODO - DEFENSE MODIFIERS AND SHRED
    }
    
    func calculateReactionMultiplier(){
        //MARK: TODO - TRANSFORMATIVE REACTIONS
        
        //Amplifying Reactions
        let baseReactionMulti = returnBaseMulti(element: self.element, reaction: self.reaction)
        var reactionAmplifyValue:Float = 0 // baseReactionMulti * (1 + %EMAmpValue + %reactionBonus)
        
        let EMStatValue = (Float(self.EMValue) ?? 0)
        let EMAmpValue = 2.78 * ((EMStatValue)/(EMStatValue + 1400))
        
//        reactionAmplifyValue = baseReactionMulti * (1 + EMAmpValue + reactionBonusValue)
        reactionAmplifyValue = baseReactionMulti * (1 + EMAmpValue)
        self.reactionMultiplier = reactionAmplifyValue
    }
    
    func calculateTotalDamage()->Int{
        if reactionMultiplier == 0{
            return self.incomingDamage
        }
        return Int(Float(self.incomingDamage) * self.reactionMultiplier)
    }
    
    func initValues(){
        self.calculateRawCharaDamage()
        self.calculateIncomingDamage()
        self.calculateReactionMultiplier()
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
                return 2
            }else if element == .pyro{
                return 1.5
            }
        default:
            return 0
        }
        return 0
    }
    
    func resetReactionValues(){
        if self.element != .hydro || self.element != .cryo || self.element != .pyro{
            self.willReaction = false
            self.EMValue = "0"
            self.reaction = .none
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
