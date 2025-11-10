//
//  StructClassActorBootcamp8.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 10.11.2025.
//  https://www.youtube.com/watch?v=-JLenSTKEcA

/*
 VALUE TYPES:
 - Struct, Enum, String, Int, etc.
 - Stored in the Stack
 - Faster
 - Thread safe!
 - When you assign or pass value type a new copy of data is created
 
 REFERENCE TYPES:
 - Class, Function, Actor
 - Stored in the Heap
 - Slower, but synchronized
 - NOT Thread safe
 - When you assign or pass reference type a new reference to original instance will be created (pointer)
 
 - - - — - - - — - - - — - - - — - - - — - - - —
 
 STACK:
 - Stores Value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has it's own stack!
 
 HEAP:
 - Stores Reference types
 - Shared across threads!
 
 - - - — - - - — - - - — - - - — - - - — - - - —
 
 STRUCT:
 - Based on VALUES
 - Can me mutated
 - Stored in the Stack!
 
 CLASS:
 - Based on REFERENCES (INSTANCES)
 - Stored in the Heap!
 - Inherit from other classes
 
 ACTOR:
 - Same as Class, but thread safe!
 
 - - - — - - - — - - - — - - - — - - - — - - - —
 
 */

import SwiftUI

struct StructClassActorBootcamp8: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                actorTest1()
            }
    }
    
    private func actorTest1() {
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting title!")
            await print("ObjectA: ", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB.")
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            await objectB.updateTitle(newTitle: "Second title!")
            
            print( "ObjectB title changed.")
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
        }
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

#Preview {
    StructClassActorBootcamp8()
}
