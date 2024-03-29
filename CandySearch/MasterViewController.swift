/*
* Copyright (c) 2017 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// MARK: - Properties
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchFooter: SearchFooter!

	var detailViewController: DetailViewController? = nil
	var candies = [Candy]()
	let searchController = UISearchController(searchResultsController: nil)
	var filteredCandies = [Candy]()
	

	// MARK: - View Setup
	override func viewDidLoad() {
		super.viewDidLoad()
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Candies"
		navigationItem.searchController = searchController
		definesPresentationContext = true

		// Setup the Scope Bar
		searchController.searchBar.scopeButtonTitles = ["All", "Chocolate", "Hard", "Other"]
		searchController.searchBar.delegate = self

		// Setup the search footer
		tableView.tableFooterView = searchFooter



		candies = [
			Candy(category:"Chocolate", name:"Chocolate Bar"),
			Candy(category:"Chocolate", name:"Chocolate Chip"),
			Candy(category:"Chocolate", name:"Dark Chocolate"),
			Candy(category:"Hard", name:"Lollipop"),
			Candy(category:"Hard", name:"Candy Cane"),
			Candy(category:"Hard", name:"Jaw Breaker"),
			Candy(category:"Other", name:"Caramel"),
			Candy(category:"Other", name:"Sour Chew"),
			Candy(category:"Other", name:"Gummi Bear"),
			Candy(category:"Other", name:"Candy Floss"),
			Candy(category:"Chocolate", name:"Chocolate Coin"),
			Candy(category:"Chocolate", name:"Chocolate Egg"),
			Candy(category:"Other", name:"Jelly Beans"),
			Candy(category:"Other", name:"Liquorice"),
			Candy(category:"Hard", name:"Toffee Apple")
		]


		if let splitViewController = splitViewController {
			let controllers = splitViewController.viewControllers
			detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		if splitViewController!.isCollapsed {
			if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
				self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
			}
		}
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Table View
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering() {
			searchFooter.setIsFilteringToShow(filteredItemCount: filteredCandies.count, of: candies.count)
			return filteredCandies.count
		}

		searchFooter.setNotFiltering()
		return candies.count
	}



	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		let candy: Candy
		if isFiltering() {
			candy = filteredCandies[indexPath.row]
		} else {
			candy = candies[indexPath.row]
		}
		cell.textLabel!.text = candy.name
		cell.detailTextLabel!.text = candy.category
		return cell
	}


	// MARK: - Private instance methods

	func searchBarIsEmpty() -> Bool {
		// Returns true if the text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}

	func filterContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredCandies = candies.filter({( candy : Candy) -> Bool in
			let doesCategoryMatch = (scope == "All") || (candy.category == scope)

			if searchBarIsEmpty() {
				return doesCategoryMatch
			} else {
				return doesCategoryMatch && candy.name.lowercased().contains(searchText.lowercased())
			}
		})
		tableView.reloadData()
	}


	func isFiltering() -> Bool {
		let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
		return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
	}




	// MARK: - Segues
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			if let indexPath = tableView.indexPathForSelectedRow {
				let candy: Candy
				if isFiltering() {
					candy = filteredCandies[indexPath.row]
				} else {
					candy = candies[indexPath.row]
				}

				let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.detailCandy = candy
				controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}
}

extension MasterViewController: UISearchResultsUpdating {
	// MARK: - UISearchResultsUpdating Delegate
	func updateSearchResults(for searchController: UISearchController) {
		let searchBar = searchController.searchBar
		let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
		filterContentForSearchText(searchController.searchBar.text!, scope: scope)
	}

}

extension MasterViewController: UISearchBarDelegate {
	// MARK: - UISearchBar Delegate
	func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
		filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
	}
}

