inventoryImport('001200001880').
inventoryImport('007874239084').
inventoryImport('003120002931').
inventoryImport('075928360007').
inventoryImport('075928367321').
inventoryImport('007874200020').
inventoryImport('007374200020').
inventoryImport('007874200020').
inventoryImport('007874200018').
inventoryImport('002740022402').
inventoryImport('007874212195').
inventoryImport('007874212195').
inventoryImport('005210001012').
inventoryImport('005200111012').
inventoryImport('005200001012').
inventoryImport('005200001012').
inventoryImport('001800000799').
inventoryImport('007874243315').
inventoryImport('017874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('007874243316').
inventoryImport('000701531262').
inventoryImport('069863908005').
inventoryImport('007432600012').

%% computeChecksum(UPC,UPCWithChecksumDigit) :-
%% 	findall(Result,
%% 		(
%% 		 between(0,9,X),
%% 		 concat_atom(['eancheck ',UPC,X],Command),
%% 		 p(Command),
%% 		 shell_command_to_string(Command,'Check digit correct\n'),
%% 		 concat_atom([UPC,X],Result)
%% 		),
%% 		[UPCWithChecksumDigit]).

computeChecksum(UPC,UPCWithChecksumDigit) :-
	concat_atom(['./checksum.pl "',UPC,'"'],Command),
	shell_command_to_string(Command,UPCWithChecksumDigit).

lookupInventory :-
	inventoryImport(Barcode),
	concat_atom(['0',Tmp],Barcode),
	p(Tmp),
	computeChecksum(Tmp,NewBarcode),
	p(NewBarcode),
	atom_number(NewBarcode,Number),
	once((
	      lookup_branded_food_by_barcode(Number,FDC_ID,DESC),
	      p(FDC_ID),
	      p(DESC)
	     )),
	%% once(food_nutrition_by_fdc_id(FDC_ID,_)),
	fail.
lookupInventory.