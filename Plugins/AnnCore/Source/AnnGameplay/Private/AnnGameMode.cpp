// Copyright Epic Games, Inc. All Rights Reserved.

#include "AnnGameMode.h"
#include "AnnCharacter.h"
#include "UObject/ConstructorHelpers.h"

AAnnGameMode::AAnnGameMode()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnBPClass(TEXT("/Game/ThirdPerson/Blueprints/BP_ThirdPersonCharacter"));
	if (PlayerPawnBPClass.Class != NULL)
	{
		DefaultPawnClass = PlayerPawnBPClass.Class;
	}
}
