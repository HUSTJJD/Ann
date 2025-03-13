

#pragma once

#include "AnnBlueprintFunctionLibrary.generated.h"
#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"

/**
 *
 */
UCLASS()
class ANNCORE_API UAnnBlueprintFunctionLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

#pragma region file system
	UFUNCTION(BlueprintCallable)
	static void FindFiles(const FString& InPath, const FString& Extension, const bool bRecursively, TArray<FString>& OutFiles);

#pragma endregion
};
