//
//  SendableBootcamp11.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Валерий Д on 12.11.2025.
//

import SwiftUI

actor CurrentUserManager {
    
    func updateDatabase(userInfo: MyClassesUserInfo) {
        
    }
}

/*
 Sendable - это протокол-маркер, который указывает, что тип безопасен для передачи между конкурентными контекстами (между акторами, Task'ами, потоками). Он гарантирует отсутствие data race при параллельном доступе.
 Sendable автоматически соответствуют: struct с Sendable-полями, enum, actor, неизменяемые классы (let свойства).
 
 Классы с var свойствами НЕ могут быть автоматически Sendable, так как могут вызвать data race.
 */
struct MyUserInfo: Sendable {
    var name: String
}

/*
 @unchecked Sendable - отключает автоматическую проверку компилятора на соответствие Sendable. Мы берем на себя ответственность за обеспечение потокобезопасности вручную
 @unchecked Sendable используется когда класс не соответствует требованиям Sendable (имеет var свойства), но мы гарантируем потокобезопасность через другие механизмы (в данном случае - через очередь)
 */
final class MyClassesUserInfo: @unchecked Sendable {
    
    
    var name: String
    
    // Создаем отдельную serial очередь для синхронизации доступа к изменяемым свойствам. Serial queue гарантирует, что операции выполняются последовательно, по одной за раз, это предотвращает data race - одновременный доступ к name из разных потоков
    let queue = DispatchQueue(label: "com.myapp.MyClassesUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    // Все изменения мутабельного состояния происходят внутри queue.async, это обеспечивает потокобезопасность: только один поток может изменять name в любой момент времени
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

final class SendableBootcampViewModel: ObservableObject {
    
    private let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyClassesUserInfo(name: "info")
        
        await manager.updateDatabase(userInfo: info)
    }
    
}

struct SendableBootcamp11: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                await viewModel.updateCurrentUserInfo()
            }
    }
}

#Preview {
    SendableBootcamp11()
}
