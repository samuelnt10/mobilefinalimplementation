//
//  ContentView.swift
//  finalimplementation
//
//  Created by
//Samuel Ntambwe - 101356457

import SwiftUI
import SQLite3

// Model for a product
struct Product: Identifiable {
    var id = UUID()
    var name: String
    var price: Double
    var category: String
}

// ViewModel to handle business logic
class ShoppingListViewModel: ObservableObject {
    @Published var products: [Product] = []
    
    // Function to add a product to the list
    func addProduct(name: String, price: Double, category: String) {
        let newProduct = Product(name: name, price: price, category: category)
        products.append(newProduct)
    }
    
    // Function to remove all products
    func removeAllProducts() {
        products.removeAll()
    }
    
    // Function to calculate total price with tax
    func calculateTotal() -> Double {
        let totalPrice = products.reduce(0) { $0 + $1.price }
        let tax = totalPrice * 0.1 // Assuming 10% tax rate
        return totalPrice + tax
    }
}

// SwiftUI View
struct ContentView: View {
    @StateObject var viewModel = ShoppingListViewModel()
    @State private var productName = ""
    @State private var productPrice = ""
    @State private var selectedCategory = ""
    @State private var showingCart = false
    
    let categories = ["Food", "Medication", "Cleaning Products"]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Add New Product")) {
                        TextField("Product Name", text: $productName)
                        TextField("Price", text: $productPrice)
                            .keyboardType(.decimalPad)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) {
                                Text($0)
                            }
                        }
                        Button(action: {
                            guard let price = Double(productPrice) else { return }
                            viewModel.addProduct(name: productName, price: price, category: selectedCategory)
                            productName = ""
                            productPrice = ""
                            selectedCategory = ""
                        }) {
                            Text("Add Product")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    
                    Section(header: Text("Shopping List")) {
                        ForEach(viewModel.products) { product in
                            Text("\(product.name) - $\(product.price) (\(product.category))")
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                
                Button(action: {
                    showingCart.toggle()
                }) {
                    Text("Go to Cart")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showingCart) {
                    CartView(viewModel: viewModel)
                }
            }
            .navigationTitle("Shopping List")
        }
    }
}

// Cart View
struct CartView: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingPurchaseScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Shopping Cart")) {
                        ForEach(viewModel.products) { product in
                            Text("\(product.name) - $\(product.price) (\(product.category))")
                        }
                    }
                    
                    Section(header: Text("Total Price with Tax")) {
                        Text("$\(viewModel.calculateTotal(), specifier: "%.2f")")
                    }
                }
                .listStyle(GroupedListStyle())
                
                HStack {
                    Button(action: {
                        showingPurchaseScreen.toggle()
                    }) {
                        Text("Purchase")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        viewModel.removeAllProducts()
                    }) {
                        Text("Clear Cart")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("Shopping Cart")
            .navigationBarItems(trailing: Button("Done") {
                viewModel.removeAllProducts()
            })
            .sheet(isPresented: $showingPurchaseScreen) {
                PurchaseView(viewModel: viewModel)
            }
        }
    }
}

// Purchase View
struct PurchaseView: View {
    @State private var creditCardNumber = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: ShoppingListViewModel
    @State private var showingThankYou = false
    
    var body: some View {
        
        VStack {
            TextField("Credit Card Number", text: $creditCardNumber)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            TextField("Expiration Date", text: $expirationDate)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            TextField("CVV", text: $cvv)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            Button(action: {
                showingThankYou = true
            }) {
                Text("Confirm Purchase")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding()
            .sheet(isPresented: $showingThankYou) {
                ThankYouView()
            }
        }
        .padding()
        .navigationTitle("Purchase")
    }
}

// Thank You View
struct ThankYouView: View {
    var body: some View {
        VStack {
            Text("Thank you, come again!")
                .font(.title)
                .padding()
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
