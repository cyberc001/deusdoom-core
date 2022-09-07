class ClassFinder
{
	static class<Actor> findActorClass(String clsname)
	{
		for(uint i = 0; i < allActorClasses.size(); ++i)
		{
			if(allActorClasses[i].getClassName() == clsname)
				return allActorClasses[i];
		}
		return null;
	}
}
