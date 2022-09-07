class KeyBindUtils
{
	static const int keychars[] = {96, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 8, 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 91, 93, 92, 65, 83, 68, 70, 71, 72, 74, 75, 76, 59, 39, 13, 90, 88, 67, 86, 66, 78, 77, 44, 46, 47, 32};
	static const int keyscans[] = {41, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 43, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 28, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 57, 56};
	const keyarrs_ln = 50;

	static const int nkeyscans[] = {59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 87, 88, 211, 199, 207, 201, 209,
					41, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 69, 181, 55, 74,
					15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 43, 71, 72, 73, 78,
					58, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 28, 75, 76, 77,
					42, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 79, 80, 81, 156,
					29, 56, 57, 203, 208, 200, 205, 82, 83 };
	static const string nkeynames[] = {"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "delete", "home", "end", "page up", "page down",
					   "`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "backspace", "numlock", "num /", "num *", "num -",
					   "tab", "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "[", "]", "slash", "num 7", "num 8", "num 9", "num +",
					   "capslock", "a", "s", "d", "f", "g", "h", "j", "k", "l", ";", "'", "enter", "num 4", "num 5", "num 6",
					   "shift", "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "num 1", "num 2", "num 3", "num enter",
					   "ctrl", "alt", "space", "arrow left", "arrow down", "arrow up", "arrow right", "num 0", "num ," };
	const nkeyarrs_ln = 92;

	static int keyCharToScan(int keyChar)
	{
		for(uint i = 0; i < KeyBindUtils.keyarrs_ln; ++i)
			if(KeyBindUtils.keychars[i] == keyChar){
				return KeyBindUtils.keyscans[i];
			}
		return 0;
	}

	static string keyScanToName(int keyScan)
	{
		for(uint i = 0; i < KeyBindUtils.nkeyarrs_ln; ++i)
			if(KeyBindUtils.nkeyscans[i] == keyScan){
				return KeyBindUtils.nkeynames[i];
			}
		return "";
	}

	static bool checkBind(int keyScan, string command)
	{
		int kb1, kb2;
		[kb1, kb2] = Bindings.GetKeysForCommand(command);
		return kb1 == keyScan || kb2 == keyScan;
	}
}
