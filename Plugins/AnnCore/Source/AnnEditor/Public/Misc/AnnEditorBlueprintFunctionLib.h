

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

	UFUNCTION(BlueprintCallable, Category = "AnnEditor Utilities")
	static void RunPythonFileWithDialog(const FString& FilePath);

	UFUNCTION(BlueprintCallable, Category = "AnnEditor Utilities")
	static void GetWidgetTreeTypeName(UWidgetBlueprint* WidgetBlueprint, TArray<FString>& OutWidgetType, TArray<FString>& OutWidgetName);

	UFUNCTION(BlueprintCallable, Category = "AnnEditor Utilities")
	static void GetBlueprintExportInfo(const UBlueprint* Blueprint, TArray<FBlueprintExportInfo>& OutExportInfo);

	UFUNCTION(BlueprintCallable, Category = "AnnEditor Utilities")
	static void GetBlueprintProperty(const UBlueprint* Blueprint, const FName& PropertyName, FString& PropertyValue);

	UFUNCTION(BlueprintCallable, Category = "AnnEditor Utilities")
	static bool SetBlueprintProperty(UBlueprint* Blueprint, const FName& PropertyName, const FString& PropertyValue);
};
