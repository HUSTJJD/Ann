#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintPlatformLibrary.h"
#include "UnLuaInterface.h"
#include "AnnGameInstance.generated.h"

class UAnnGameInstance;

struct FAnnTickFunction : public FTickFunction
{
	FAnnTickFunction()
	{
		TickGroup = TG_DuringPhysics;
		bTickEvenWhenPaused = true;
		bCanEverTick = true;
	}
	virtual void ExecuteTick(float DeltaTime, ELevelTick TickType, ENamedThreads::Type CurrentThread, const FGraphEventRef& MyCompletionGraphEvent) override;
	/** Abstract function to describe this tick. Used to print messages about illegal cycles in the dependency graph **/
	virtual FString DiagnosticMessage() override
	{
		return FString(TEXT("FAnnTickFunction"));
	}
	/** Function used to describe this tick for active tick reporting. **/
	virtual FName DiagnosticContext(bool bDetailed) override
	{
		return FName(TEXT("FAnnTickFunction"));
	}

	void SetGameInstance(UAnnGameInstance* Instance) { GameInstance = Instance; }

private:
	TWeakObjectPtr<UAnnGameInstance> GameInstance;
};

template <>
struct TStructOpsTypeTraits<FAnnTickFunction> : public TStructOpsTypeTraitsBase2<FAnnTickFunction>
{
	enum
	{
		WithCopy = false
	};
};

UCLASS()
class ANNCORE_API UAnnGameInstance : public UPlatformGameInstance
{
	GENERATED_BODY()

public:
	virtual void Init() override;
	virtual void Shutdown() override;
	UFUNCTION(BlueprintImplementableEvent, meta = (DisplayName = "Tick"))
	void ReceiveTick(float DeltaTime);

private:
	FAnnTickFunction AnnTickFunction;
};
