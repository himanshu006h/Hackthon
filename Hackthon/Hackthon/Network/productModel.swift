//
//  productModel.swift
//  Hackthon
//
//  Created by Manikandan Bangaru on 08/06/23.
//

import Foundation


struct WalmartResponse : Decodable {
    var search_metadata : SearchMetaData?
    var search_parameters: Search_parameters?
    var search_information: Search_information?
    var organic_results: [productDetails]?
    var pagination: Pagination?
    var serpapi_pagination: Serpapi_pagination?
}

struct SearchMetaData : Decodable {
    var id: String?
    var status: String?
    var json_endpoint: String?
    var created_at:String?
    var processed_at:String?
    var walmart_url:String?
    var raw_html_file:String?
    var total_time_taken:Double?
}

struct Search_parameters : Decodable {
    var engine: String?
    var device: String?
    var query: String?
}
struct Search_information : Decodable {
    var location: Location?
    var total_results: Int64?
    var query_displayed: String?
    var organic_results_state: String?
}
struct Location : Decodable {
    var postal_code: String?
    var province_code: String?
    var city:String?
    var store_id: String?
}
struct PrimaryOffer : Decodable {
    var offer_id:String?
    var offer_price: Double?
    var min_price: Double?
}
struct PriceUnit: Decodable {
    var unit: String?
}
struct productDetails : Decodable {
    var us_item_id: String?
    var product_id:String?
    var title: String?
    var thumbnail: String?
    var rating: Double?
    var reviews: Int64?
    var seller_id: String?
    var seller_name: String?
    var fulfillment_badges: [String]?
    var two_day_shipping: Bool?
    var out_of_stock:Bool?
    var sponsored:Bool?
    var muliple_options_available:Bool?
    var primary_offer:PrimaryOffer?
    var price_per_unit:PriceUnit?
    var product_page_url: String?
    var serpapi_product_page_url: String?
}
struct Pagination : Decodable {
    var current: Int?
    var next: String?
    var other_pages: [String: String]?
}

struct Serpapi_pagination: Decodable {
    var current: Int?
    var next: String?
    var next_link: String?
    var other_pages: [String: String]?
}
