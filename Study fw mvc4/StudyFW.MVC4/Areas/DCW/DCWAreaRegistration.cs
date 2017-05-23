using System.Web.Mvc;

namespace StudyFW.MVC4.Areas.DCW
{
	public class DCWAreaRegistration : AreaRegistration
	{
		public override string AreaName
		{
			get
			{
				return "DCW";
			}
		}

		public override void RegisterArea( AreaRegistrationContext context )
		{
			context.MapRoute(
				"DCW_default",
				"DCW/{controller}/{action}/{id}",
				new { action = "Index", id = UrlParameter.Optional }
			);
		}
	}
}