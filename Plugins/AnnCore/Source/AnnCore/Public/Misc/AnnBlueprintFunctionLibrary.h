

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "AnnBlueprintFunctionLibrary.generated.h"

/**
 * 
 */
UCLASS()
class ANNCORE_API UAnnBlueprintFunctionLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()
	
# pragma region file system
	UFUNCTION(BlueprintCallable)
	static void GetFilesInDir(const FString& InPath, TArray<FString>& OutFiles);



# pragma endregion
	
	
};
