

#include "Misc/AnnBlueprintFunctionLibrary.h"

void UAnnBlueprintFunctionLibrary::FindFiles(const FString& InPath, const FString& Extension, const bool bRecursively, TArray<FString>& OutFiles)
{
	IPlatformFile& platformFile = FPlatformFileManager::Get().GetPlatformFile();
	if (bRecursively)
		platformFile.FindFilesRecursively(OutFiles, *InPath, *Extension);
	else
		platformFile.FindFiles(OutFiles, *InPath, *Extension);
}
