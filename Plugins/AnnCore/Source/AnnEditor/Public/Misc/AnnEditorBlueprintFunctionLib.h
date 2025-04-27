

#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "AnnEditorBlueprintFunctionLib.generated.h"

class UWidgetBlueprint;
/**
 *
 */

USTRUCT(BlueprintType)
struct ANNEDITOR_API FBlueprintExportInfo
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FString Type;
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FString Name;
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FString OwnerClass;
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FString Flag;

	FBlueprintExportInfo()
		: Type(""), Name(""), OwnerClass(""), Flag("") {}
};

UCLASS()
class ANNEDITOR_API UAnnEditorBlueprintFunctionLib : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

	UFUNCTION(BlueprintCallable)
	static void RunPythonFileWithDialog(const FString& FilePath);

	UFUNCTION(BlueprintCallable)
	static void GetWidgetTreeTypeName(UWidgetBlueprint* WidgetBlueprint, TArray<FString>& OutWidgetType, TArray<FString>& OutWidgetName);

	UFUNCTION(BlueprintCallable)
	static void GetBlueprintExportInfo(const UBlueprint* Blueprint, TArray<FBlueprintExportInfo>& OutExportInfo);
};
