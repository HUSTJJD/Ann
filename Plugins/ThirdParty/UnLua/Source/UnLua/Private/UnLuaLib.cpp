#include "UnLuaLib.h"
#include "LowLevel.h"
#include "LuaEnv.h"
#include "UnLuaBase.h"

namespace UnLua
{
	namespace UnLuaLib
	{
		static const char* PACKAGE_PATH_KEY = "PackagePath";

		static FString GetMessage(lua_State* L)
		{
			const auto ArgCount = lua_gettop(L);
			FString	   Message;
			if (!lua_checkstack(L, ArgCount))
			{
				luaL_error(L, "too many arguments, stack overflow");
				return Message;
			}
			for (int ArgIndex = 1; ArgIndex <= ArgCount; ArgIndex++)
			{
				if (ArgIndex > 1)
					Message += "\t";
				Message += UTF8_TO_TCHAR(luaL_tolstring(L, ArgIndex, NULL));
			}
			return Message;
		}

		static int LogInfo(lua_State* L)
		{
			const auto Msg = GetMessage(L);
			UE_LOG(LogUnLua, Log, TEXT("%s"), *Msg);
			return 0;
		}

		static int LogWarn(lua_State* L)
		{
			const auto Msg = GetMessage(L);
			UE_LOG(LogUnLua, Warning, TEXT("%s"), *Msg);
			return 0;
		}

		static int LogError(lua_State* L)
		{
			const auto Msg = GetMessage(L);
			UE_LOG(LogUnLua, Error, TEXT("%s"), *Msg);
			return 0;
		}

		static int Ref(lua_State* L)
		{
			const auto Object = GetUObject(L, -1);
			if (!Object)
				return luaL_error(L, "invalid UObject");

			const auto& Env = FLuaEnv::FindEnvChecked(L);
			Env.GetObjectRegistry()->AddManualRef(L, Object);
			return 1;
		}

		static int Unref(lua_State* L)
		{
			const auto Object = GetUObject(L, -1);
			if (!Object)
				return luaL_error(L, "invalid UObject");

			const auto& Env = FLuaEnv::FindEnvChecked(L);
			Env.GetObjectRegistry()->RemoveManualRef(Object);
			return 0;
		}

#pragma region Legacy Support

		int32 GetUProperty(lua_State* L)
		{
			auto Ptr = lua_touserdata(L, 2);
			if (!Ptr)
				return 0;

			auto Property = static_cast<TSharedPtr<UnLua::ITypeOps>*>(Ptr);
			if (!Property->IsValid())
				return 0;

			auto Self = GetCppInstance(L, 1);
			if (!Self)
				return 0;

			if (UnLua::LowLevel::IsReleasedPtr(Self))
				return luaL_error(L, TCHAR_TO_UTF8(*FString::Printf(TEXT("attempt to read property '%s' on released object"), *(*Property)->GetName())));

			if (!LowLevel::CheckPropertyOwner(L, (*Property).Get(), Self))
				return 0;

			(*Property)->ReadValue_InContainer(L, Self, false);
			return 1;
		}

		int32 SetUProperty(lua_State* L)
		{
			auto Ptr = lua_touserdata(L, 2);
			if (!Ptr)
				return 0;

			auto Property = static_cast<TSharedPtr<UnLua::ITypeOps>*>(Ptr);
			if (!Property->IsValid())
				return 0;

			auto Self = GetCppInstance(L, 1);
			if (LowLevel::IsReleasedPtr(Self))
				return luaL_error(L, TCHAR_TO_UTF8(*FString::Printf(TEXT("attempt to write property '%s' on released object"), *(*Property)->GetName())));

			if (!LowLevel::CheckPropertyOwner(L, (*Property).Get(), Self))
				return 0;

			(*Property)->WriteValue_InContainer(L, Self, 3);
			return 0;
		}

#pragma endregion

		static constexpr luaL_Reg UnLua_Functions[] = {
			{ "Log", LogInfo },
			{ "LogWarn", LogWarn },
			{ "LogError", LogError },
			{ "Ref", Ref },
			{ "Unref", Unref },
			{ "GetUProperty", GetUProperty },
			{ "SetUProperty", SetUProperty },
			{ "HotReloadEnabled", nullptr },
			{ "FTextEnabled", nullptr },
			{ NULL, NULL }
		};

		static int LuaOpen(lua_State* L)
		{
			lua_newtable(L);
			luaL_setfuncs(L, UnLua_Functions, 0);
			lua_pushstring(L, "Content/?.lua");
			lua_setfield(L, -2, PACKAGE_PATH_KEY);
			return 1;
		}

		int Open(lua_State* L)
		{
			lua_register(L, "print", LogInfo);
			luaL_requiref(L, "UnLua", LuaOpen, 1);
#if UNLUA_WITH_HOT_RELOAD
			luaL_dostring(L, "UnLua.HotReloadEnabled = true");
#endif
#if UNLUA_ENABLE_FTEXT
			luaL_dostring(L, "UnLua.FTextEnabled = true");
#endif
			luaL_dostring(L, R"(
				pcall(function() require('UnLua.__Init__') end)	
            )");
			lua_pop(L, 1);
			return 1;
		}

		FString GetPackagePath(lua_State* L)
		{
			lua_getglobal(L, "UnLua");
			checkf(lua_istable(L, -1), TEXT("UnLuaLib not registered"));
			lua_getfield(L, -1, PACKAGE_PATH_KEY);
			const auto PackagePath = lua_tostring(L, -1);
			checkf(PackagePath, TEXT("invalid PackagePath"));
			lua_pop(L, 2);
			return UTF8_TO_TCHAR(PackagePath);
		}

		void SetPackagePath(lua_State* L, const FString& PackagePath)
		{
			lua_getglobal(L, "UnLua");
			checkf(lua_istable(L, -1), TEXT("UnLuaLib not registered"));
			lua_pushstring(L, TCHAR_TO_UTF8(*PackagePath));
			lua_setfield(L, -2, PACKAGE_PATH_KEY);
			lua_pop(L, 2);
		}
	} // namespace UnLuaLib
} // namespace UnLua
