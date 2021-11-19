//
//  ContentView.swift
//  PrimogemCalculator
//
//  Created by Jesse Joseph on 25/08/21.
//

import SwiftUI

struct PrimogemView: View {
    
    @State private var isWelkin = false
    @State private var isBP = false
    @State private var days:Int = 5
    @State private var BPLevel = 0
    
    @State private var calculateDefault:Bool = true
    @State private var passedFloor8:Bool = false
    
    @State private var worstCase:Int = 0
    @State private var bestCase:Int = 0
    
    let defaultDays = 40
    let spiralFloors = [9,10,11,12]
    
    @State private var spiralRatings = [0,0,0,0]
    @State private var isFinishedCalculating = false
    
    var body: some View {
        NavigationView{
            Form{
                //TIME
                Section(header:Text("TimeFrame")){
                    VStack(alignment:.leading, spacing:0){
                        Toggle("Calculate for one version", isOn: $calculateDefault)
                        Text("One version is regarded as 40 Days")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    
                    if !calculateDefault{
                        Stepper("Total Day Calculated: \(days)", value: $days, in: 5...40, step: 5)
                    }
                    
                }
                //SPIRAL ABYSS
                Section(header: Text("Spiral Abyss")){
                    Toggle("Have you passed Abyss floor 8?", isOn: $passedFloor8)
                    if passedFloor8{
                        ForEach (0..<spiralFloors.count){index in
                            Stepper("Floor \(spiralFloors[index]) stars: \(spiralRatings[index])", value: $spiralRatings[index], in:0...9, step: 3)
                        }
                        
                    }
                }
                //BP PREMIUM AND WELKIN
                Section(header: Text("BP and Welkin")){
                    Toggle("Bought BP", isOn: $isBP)
                    if isBP{
                        VStack{
                            Stepper("BP Level: \(BPLevel)", value: $BPLevel, in: 0...50, step: 1)
                            Text("Premium BP will assume you get max xp per week")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                        
                    }
                    Toggle("Bought Monthly Welkin", isOn: $isWelkin)
                }
                
                Section{
                    Button(action: {
                        self.calculateTotalGems()
                    }, label: {
                        Text("Calculate")
                    })
                }
                
                if isFinishedCalculating{
                    Section(header:Text("Calculation")){
                        
                        Text("Worst Case Scenario Gem: \(worstCase) primos")
                        Text("Best Case Scenario Gem: \(bestCase) primos")
                        let worstSummon = worstCase/160
                        let bestSummon = bestCase/160
                        VStack(alignment:.leading){
                            Text("Translates to \(worstSummon)-\(bestSummon) summons")
                            Text("This includes primogems and Intertwined Fate only")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Text("This doesn't account for web events or big events or login bonuses or new region content")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                    }
                }
            }
            .navigationBarTitle("Primogem Calculator")
        }
    }
    
    func calculateTotalGems(){
        isFinishedCalculating = false
        bestCase = 0
        worstCase = 0
        
        calculateTimedGems()
        
        if passedFloor8{
            calculateSpiralGems()
        }
        
        if isBP{
            calculateBP()
        }
        
        print(worstCase)
        print(bestCase)
        
        self.isFinishedCalculating = true
    }
    
    func calculateBP(){
        let weeks:Float = Float(days/7)
        var BPIncrease = Int(weeks*10)
        
        let FutureBPLevel = BPLevel + BPIncrease
        if FutureBPLevel > 50{
            BPIncrease = 50-BPLevel
        }
        
        let intertwinedTotal = BPIncrease/10
        
        bestCase += intertwinedTotal*160
        worstCase += intertwinedTotal*160
    }
    
    func calculateSpiralGems(){
        var totalStar = 0
        var totalReward:Int = 0
        
        //calculate stars
        for stars in spiralRatings{
            totalStar += stars
        }
        
        //50 primos per 3 stars
        totalReward = (totalStar/3) * 50
        
        let rotation = Int(days/14)
        if rotation > 0{
            if rotation > 1{
                worstCase += (rotation-1) * totalReward
            }
            
            bestCase += rotation * totalReward
        }
    }
    
    func calculateTimedGems(){
        var total = 0
        //CALCULATE DAYS
        if calculateDefault{
            days = defaultDays
        }
        
        //DAILY
        let dailyReward = 60
        let totalDaily = days * dailyReward
        total += totalDaily
        
        //CHECK IF WELKIN
        if isWelkin{
            let dailyWelkin = 90
            let totalWelkin = days*dailyWelkin
            total += totalWelkin
        }
        
        worstCase += total
        
        //EVENTS
        let weeks = Int(days/7)
        if weeks > 0{
            let eventAssumption = 420
            let totalEvent = weeks*eventAssumption
            total += totalEvent
            
            //worst case only one less week worth of event
            if weeks > 1{
                let worstCaseEvent = weeks - 1
                worstCase += worstCaseEvent * eventAssumption
            }
        }
        
        //STORE RESET
        if days >= 30{
            //5 Intertwined
            total += 5 * 160
        }
        
        bestCase = total
    }
}

struct PrimogemView_Previews: PreviewProvider {
    static var previews: some View {
        PrimogemView()
    }
}
