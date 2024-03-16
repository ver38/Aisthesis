//
//  ContentView.swift
//  Aisthesis
//
//  Created by Veronica Natale on 13/03/24.
//

import SwiftUI
import AVFoundation
import AVKit


struct ContentView: View {
    var body: some View {
        Home()
    }
}

#Preview {
    ContentView()
}


struct Home: View {
    
    @State var record = false
    @State var session : AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var alert = false
    
    // fetch dell audio
    @State var audios : [URL] = []
    
   // () -> PrimitiveButtonStyleConfiguration.Label in
    var body: some View {
        NavigationView{
            
            VStack {
                
                List(self.audios, id: \.self) {i in
                    
                    Text(i.relativeString)
                    
                    
                    
                }
                
                Button(action: {
                
                    do {
//                        
                        if self.record{
                            
                            self.recorder.stop()
                            self.record.toggle()
                            // updating data for every recording
                            self.getAudios()
                            return
                        }
                        
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.appendingPathComponent("myaudio\(self.audios.count + 1).m4a")
                        
                        let settings = [
                            
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey : 12000,
                            AVNumberOfChannelsKey : 1,
                            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
                            
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                        self.recorder.record()
                        self.record.toggle()

                    }
                    catch {
                        
                        print(error.localizedDescription)
                        
                    }
                }) {
                    
                    ZStack{
                        Circle()
                            .fill(Color.red)
                            .frame(width: 70, height: 70)
                        
                        if self.record{
                            
                            Circle()
                                .stroke(Color.red, lineWidth: 6)
                                .frame(width: 90, height: 90)
                            
                        }
                        
                    }
                    
                }
                .padding(.vertical, 25)
            }
            .navigationBarTitle("Aisthesis")
            
        }
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("Action required"), message: Text("Enable access to microphone"))
        })
        .onAppear{ 
            
            do{
                
                //inizializza l audio session quando crea la view
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.playAndRecord)
                
                //richiedi autorizzazione per registrare
                self.session.requestRecordPermission { (status) in
                    
                    if !status{
                        
                        self.alert.toggle()
                    }
                    else {
                        
                        self.getAudios()
                    }
                    
                }
                
            }
            catch {
                
                print(error.localizedDescription)
            }
            
        }
    }
    
    func getAudios() {
        
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // fetch all data from document directory
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            // Stampa i percorsi dei file audio nella console di debug
                    for audioURL in result {
                        print("Percorso del file audio: \(audioURL.path)")
                    }
            
            
            // update removes all old data
            self.audios.removeAll()
            
            for i in result {
                self.audios.append(i)
            }
            
            
        }
        catch {
            print(error.localizedDescription)
        }
        
        
    }
}
