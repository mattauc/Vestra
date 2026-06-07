//
//  EnrichmentStatus.swift
//  Vestra
//

import Foundation

/// Tracks the state of a page's externally-sourced data.
/// Set to `.enriching` when a page is created and waiting on the backend;
/// `.ready` once the worker writes the enriched data; `.failed` on error.
enum EnrichmentStatus: String, Codable, Hashable {
    case enriching
    case ready
    case failed
}
