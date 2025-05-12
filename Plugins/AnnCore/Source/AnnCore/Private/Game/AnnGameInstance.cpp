#include "Game/AnnGameInstance.h"

void FAnnTickFunction::ExecuteTick(float DeltaTime, ELevelTick TickType, ENamedThreads::Type CurrentThread, const FGraphEventRef& MyCompletionGraphEvent)
{
	if (GameInstance.IsValid() && GameInstance->IsValidLowLevelFast())
	{
		GameInstance->ReceiveTick(DeltaTime);
	}
}

FString UAnnGameInstance::GetModuleName_Implementation() const
{
	return TEXT("Startup.AnnGameInstance");
}

void UAnnGameInstance::Init()
{
	Super::Init();
	if (const auto World = GetWorld())
	{
		if (const auto Level = World->PersistentLevel)
		{
			AnnTickFunction.RegisterTickFunction(Level);
			AnnTickFunction.SetGameInstance(this);
		}
	}
}

void UAnnGameInstance::Shutdown()
{
	AnnTickFunction.UnRegisterTickFunction();
	AnnTickFunction.SetGameInstance(nullptr);
	Super::Shutdown();
}
