// Copyright Epic Games, Inc. All Rights Reserved.

#include "AnnGameMode.h"
#include "AnnCharacter.h"
#include "GameFramework/GameState.h"
#include "GameFramework/HUD.h"
#include "GameFramework/PlayerState.h"
#include "GameFramework/SpectatorPawn.h"
#include "UObject/ConstructorHelpers.h"

AAnnGameMode::AAnnGameMode()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> AnnCharacterClass(TEXT("/Script/AnnGameplay.AnnCharacter"));
	if (AnnCharacterClass.Class)
	{
		DefaultPawnClass = AnnCharacterClass.Class;
	}
	static ConstructorHelpers::FClassFinder<AHUD> AnnHUDClass(TEXT("/Script/AnnGameplay.AnnHUD"));
	if (AnnHUDClass.Class)
	{
		HUDClass = AnnHUDClass.Class;
	}
	static ConstructorHelpers::FClassFinder<APlayerController> AnnPlayerControllerClass(TEXT("/Script/AnnGameplay.AnnPlayerController"));
	if (AnnPlayerControllerClass.Class)
	{
		PlayerControllerClass = AnnPlayerControllerClass.Class;
	}
	static ConstructorHelpers::FClassFinder<AGameState> AnnGameStateClass(TEXT("/Script/AnnGameplay.AnnGameState"));
	if (AnnGameStateClass.Class)
	{
		GameStateClass = AnnGameStateClass.Class;
	}
	static ConstructorHelpers::FClassFinder<APlayerState> AnnPlayerStateClass(TEXT("/Script/AnnGameplay.AnnPlayerState"));
	if (AnnPlayerStateClass.Class)
	{
		PlayerStateClass = AnnPlayerStateClass.Class;
	}
	static ConstructorHelpers::FClassFinder<ASpectatorPawn> AnnSpectatorPawnClass(TEXT("/Script/AnnGameplay.AnnSpectatorPawn"));
	if (AnnSpectatorPawnClass.Class)
	{
		SpectatorClass = AnnSpectatorPawnClass.Class;
	}
}
