//---------------------------------------------------------------------------
// Version			: 001
// Designer			: QuanNH7-FPT
// Programmer		: QuanNH7-FPT
// Date				: 2015/03/31
// Comment			: Create new
//---------------------------------------------------------------------------

using System.Web.Mvc;

namespace StudyFW.MVC4
{
	public class FilterConfig
	{
		public static void RegisterGlobalFilters( GlobalFilterCollection filters )
		{
			filters.Add( new HandleErrorAttribute() );
		}
	}
}