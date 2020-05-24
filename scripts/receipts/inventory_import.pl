:- ensure_loaded('/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/receipts/inventory_import_data.pl').

lookupBrandedFoodByBarcode(Barcode,Description) :-
	branded_food(FDC_ID,_,Barcode,_,_,_,_,_,_,_,_),
	getFoodDescFromFDCID(FDC_ID,Description).

pr(Item) :-
	print_term(Item,[quoted(true)]),nl.

printInventoryMatches :-
	findall(Description,(inventoryImport(Barcode),atom_number(Barcode,Number),lookupBrandedFoodByBarcode(Number,Description)),Descriptions),
	p(Descriptions).
