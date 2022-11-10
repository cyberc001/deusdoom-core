class DD_DXText : DD_DXLogo
{
	default
	{
		+NOGRAVITY;
		+NOBLOCKMAP;

		Scale 0.17;
		DD_DXLogo.AngleSpeed 0.25;
		DD_DXLogo.FloatExponent 1.2;
		DD_DXLogo.MinFloatspeed 0.25;
	}

	states
	{
		Spawn:
			DDTX A 1;
			Loop;
	}

	override void BeginPlay()
	{
		super.BeginPlay();
		A_SetAngle(angle - 45);
	}

	override void Tick()
	{
		super.Tick();
		if(angle > 0){
			ang_speed *= 0.5;
		}
	}
}
