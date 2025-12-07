//
//  ContentView.swift
//  Shimmer
//
//  Created by Noman belim on 07/12/25.
//
import SwiftUI
import UniversalShimmer
import SwiftUI
import UniversalShimmer

struct ContentView: View {
    @StateObject private var vm = JobViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
              

                if vm.isLoading {
                    Text("Job Details")
                        .font(.largeTitle.bold())
                        .shimmer(active: true)
                    JobSkeletonView()        // ← shimmer placeholder
                } else if let job = vm.job {
                    JobDetailView(job: job)  // ← real API data
                    Text("Job Details")
                        .font(.largeTitle.bold())
                }
                
                Button(vm.isLoading ? "Loading..." : "Reload Job") {
                    vm.isLoading = true
                    vm.fetchJob()
                }
                .font(.title3)
                .padding(.top, 20)
            }
            .padding()
        }
        .onAppear {
            vm.fetchJob()
        }
    }
}
 
struct JobResponse: Decodable {
    let success: Bool
    let message: String
    let data: JobData
}

struct JobData: Decodable {
    let id: Int
    let title: String
    let shortDescription: String
    let jobRoleDescription: String
    let companyName: String
    let location: String
    let salaryMin: Int?
    let salaryMax: Int?
}

import Foundation

class JobViewModel: ObservableObject {
    @Published var job: JobData?
    @Published var isLoading = true

    func fetchJob() {
        guard let url = URL(string: "https://xrrest.testingbeta.in/api/v1/jobs/48") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("API Error:", error.localizedDescription)
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    print("❌ No Data")
                    self.isLoading = false
                    return
                }

                do {
                    let result = try JSONDecoder().decode(JobResponse.self, from: data)
                    self.job = result.data
                } catch {
                    print("❌ Decoding error:", error)
                }

                self.isLoading = false
            }
        }.resume()
    }
}

struct JobSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            SkeletonText(width: 200, height: 24) // Title
            SkeletonText(width: 140, height: 18) // Company
            SkeletonText(width: 160, height: 18) // Location
            SkeletonText(width: 180, height: 18) // Salary
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .shimmer()
    }
}

struct JobDetailView: View {
    let job: JobData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(job.title)
                .font(.title2.bold())

            Text(job.companyName)
                .font(.headline)

            Text("Location: \(job.location)")
                .font(.subheadline)

            if let min = job.salaryMin, let max = job.salaryMax {
                Text("Salary: ₹\(min) - ₹\(max)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

            Text("Description: \(job.shortDescription)")
                .font(.body)
                .padding(.top, 6)

        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    ContentView()
}
