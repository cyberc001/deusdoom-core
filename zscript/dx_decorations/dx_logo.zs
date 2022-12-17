class DD_DXLogo : actor
{
	default
	{
		+NOGRAVITY;
		+NOBLOCKMAP;

		DD_DXLogo.AngleSpeed -1.5;
		DD_DXLogo.FloatExponent 1.15;
		DD_DXLogo.FloatSpeed 8;
		DD_DXLogo.MinFloatSpeed 0.25;
	}

	states
	{
		Spawn:
			DDLG A 1;
			Loop;
	}

	vector3 desired_pos;
	double max_pos_diff;
	override void BeginPlay()
	{
		desired_pos = pos;
		Warp(self, 400, 0, 0, WARPF_ABSOLUTEOFFSET);
		max_pos_diff = (desired_pos - pos).length();
	}

	double ang_speed;
	property AngleSpeed: ang_speed;
	double float_speed;
	property FloatSpeed: float_speed;
	double min_float_speed;
	property MinFloatSpeed: min_float_speed;
	double float_exp;
	property FloatExponent: float_exp;

	override void Tick()
	{
		super.Tick();
		A_SetAngle(angle + ang_speed);

		vector3 pos_diff = desired_pos - pos; 
		if(pos_diff.length() > float_speed * min_float_speed){
			double spmult = (pos_diff.length() / max_pos_diff)**float_exp;
			if(spmult < min_float_speed) spmult = min_float_speed;
			pos_diff /= pos_diff.length();
			pos_diff *= (float_speed * spmult);
			A_ChangeVelocity(pos_diff.x, pos_diff.y, pos_diff.z, CVF_REPLACE);
		}
		else
			Warp(self, desired_pos.x, desired_pos.y, desired_pos.z, 0, WARPF_ABSOLUTEPOSITION);
	}
}
