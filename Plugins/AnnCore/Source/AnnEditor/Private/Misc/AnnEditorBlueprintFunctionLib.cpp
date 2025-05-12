#include "Misc/AnnEditorBlueprintFunctionLib.h"
#include "EditorDialogLibrary.h"
#include "FileHelpers.h"
#include "IPythonScriptPlugin.h"
#include "Blueprint/WidgetTree.h"
#include "Editor/UMGEditor/Public/WidgetBlueprint.h"
#include "Kismet/KismetSystemLibrary.h"
#include "Kismet2/KismetEditorUtilities.h"

void UAnnEditorBlueprintFunctionLib::RunPythonFileWithDialog(const FString& FilePath)
{
	FPythonCommandEx Context;
	Context.Command = FPaths::Combine(UKismetSystemLibrary::GetProjectContentDirectory(), FilePath);
	const auto bSuccess = IPythonScriptPlugin::Get()->ExecPythonCommandEx(Context);
	FString	   Message;
	for (const FPythonLogOutputEntry& OutputEntry : Context.LogOutput)
	{
		Message.Append(OutputEntry.Output);
	}
	UEditorDialogLibrary::ShowMessage(FText::FromString(Context.CommandResult), FText::FromString(Message), EAppMsgType::YesNo, EAppReturnType::No, bSuccess ? EAppMsgCategory::Info : EAppMsgCategory::Error);
}

void UAnnEditorBlueprintFunctionLib::GetWidgetTreeTypeName(UWidgetBlueprint* WidgetBlueprint, TArray<FString>& OutWidgetType, TArray<FString>& OutWidgetName)
{
	if (WidgetBlueprint)
	{
		if (const UWidgetTree* WidgetTree = WidgetBlueprint->WidgetTree)
		{
			WidgetTree->ForEachWidget([&OutWidgetType, &OutWidgetName](const UWidget* Widget) {
				if (Widget && Widget->bIsVariable)
				{
					OutWidgetType.Add(Widget->GetClass()->GetName());
					OutWidgetName.Add(Widget->GetName());
				}
			});
		}
	}
}

void UAnnEditorBlueprintFunctionLib::GetBlueprintExportInfo(const UBlueprint* Blueprint, TArray<FBlueprintExportInfo>& OutExportInfo)
{
	if (!Blueprint)
	{
		return;
	}
	if (const UClass* Class = Blueprint->GeneratedClass)
	{
		for (TFieldIterator<FProperty> PropIt(Class, EFieldIteratorFlags::IncludeSuper); PropIt; ++PropIt)
		{
			const FProperty* Property = *PropIt;
			if (!Property->HasAnyPropertyFlags(CPF_BlueprintVisible) && !Property->HasAnyPropertyFlags(CPF_ExportObject))
			{
				continue;
			}
			FBlueprintExportInfo Info;
			Info.Type = Property->GetCPPType().Replace(TEXT("*"), TEXT(""));
			Info.Name = Property->GetName();
			if (Property->HasAnyPropertyFlags(CPF_RepNotify))
			{
				Info.Flag = "RepNotify";
			}
			else if (Property->HasAnyPropertyFlags(CPF_Net))
			{
				Info.Flag = "Replicated";
			}
			Info.OwnerClass = Property->GetOwnerClass()->GetName();
			OutExportInfo.Add(Info);
		}
		for (TFieldIterator<UFunction> FuncIt(Class, EFieldIteratorFlags::IncludeSuper); FuncIt; ++FuncIt)
		{
			FBlueprintExportInfo Info;
			const UFunction*	 Function = *FuncIt;
			if (Function->HasAnyFunctionFlags(FUNC_NetServer))
			{
				Info.Flag = "NetServer";
			}
			else if (Function->HasAnyFunctionFlags(FUNC_NetClient))
			{
				Info.Flag = "NetClient";
			}
			else if (Function->HasAnyFunctionFlags(FUNC_NetMulticast))
			{
				Info.Flag = "NetMulticast";
			}
			else if (Function->HasAnyFunctionFlags(FUNC_BlueprintEvent))
			{
				Info.Flag = "BlueprintEvent";
			}
			else if (Function->HasAnyFunctionFlags(FUNC_BlueprintCallable))
			{
				Info.Flag = "BlueprintCallable";
			}
			else
			{
				continue;
			}
			Info.Type = "UFunction";
			Info.Name = Function->GetName();
			Info.OwnerClass = Function->GetOwnerClass()->GetName();
			OutExportInfo.Add(Info);
		}
	}
}

void UAnnEditorBlueprintFunctionLib::GetBlueprintProperty(const UBlueprint* Blueprint, const FName& PropertyName, FString& PropertyValue)
{
	if (Blueprint && Blueprint->GeneratedClass)
	{
		if (const FProperty* Property = Blueprint->GeneratedClass->FindPropertyByName(PropertyName))
		{
			if (UObject* DefaultObject = Blueprint->GeneratedClass->GetDefaultObject())
			{
				Property->ExportText_Direct(PropertyValue, Property->ContainerPtrToValuePtr<void>(DefaultObject), nullptr, nullptr, PPF_None);
			}
		}
	}
}

bool UAnnEditorBlueprintFunctionLib::SetBlueprintProperty(UBlueprint* Blueprint, const FName& PropertyName, const FString& PropertyValue)
{
	if (Blueprint && Blueprint->GeneratedClass)
	{
		if (FProperty* Property = Blueprint->GeneratedClass->FindPropertyByName(PropertyName))
		{
			if (UObject* DefaultObject = Blueprint->GeneratedClass->GetDefaultObject())
			{
				void* ValuePtr = Property->ContainerPtrToValuePtr<void>(DefaultObject);
				if (Property->ImportText_Direct(*PropertyValue, ValuePtr, DefaultObject, PPF_None))
				{
					FKismetEditorUtilities::CompileBlueprint(Blueprint);
					if (UEditorLoadingAndSavingUtils::SavePackages({ Blueprint->GetOutermost() }, false))
					{
						return true;
					}
				}
			}
		}
	}
	return false;
}
