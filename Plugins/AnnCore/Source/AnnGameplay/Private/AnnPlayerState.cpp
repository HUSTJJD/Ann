#include "AnnPlayerState.h"

AAnnPlayerState::AAnnPlayerState()
{
	AbilitySystemComponent = CreateDefaultSubobject<UAbilitySystemComponent>(TEXT("AbilitySystemComponent"));
	AbilitySystemComponent->SetIsReplicated(true);
}

UAbilitySystemComponent* AAnnPlayerState::GetAbilitySystemComponent() const
{
	return AbilitySystemComponent;
}