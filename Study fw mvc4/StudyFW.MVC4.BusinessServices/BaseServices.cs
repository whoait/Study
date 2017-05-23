//---------------------------------------------------------------------------
// Version			: 001
// Designer			: QuanNH7-FPT
// Programmer		: QuanNH7-FPT
// Date				: 2015/03/31
// Comment			: Create new
//---------------------------------------------------------------------------

using StudyFW.MVC4.Constants;
using StudyFW.MVC4.DataAccess.Framework;
using StudyFW.MVC4.Entities;
using StudyFW.MVC4.UtilityServices;
using System;
using System.Web;

namespace StudyFW.MVC4.BusinessServices
{
	public class BaseServices : IDisposable
	{
		private CmnEntityModel cmnEntityModel = null;

		public CmnEntityModel CmnEntityModel
		{
			get
			{
				if (cmnEntityModel == null)
				{
					cmnEntityModel = (CmnEntityModel)HttpContext.Current.Items[CacheKeys.CmnEntityModel];
				}
				return cmnEntityModel;
			}
		}

		public void Dispose( bool disposing )
		{
			if (!String.IsNullOrEmpty( this.CmnEntityModel.ErrorMsgCd ))
			{
				DBManager.RollbackTransaction();
			}
			else
			{
				DBManager.CommitTransaction();
			}
			DBManager.CloseConnection();
		}

		public void Dispose()
		{
			this.Dispose( true );
		}

		/// <summary>
		/// Gets the permision.
		/// </summary>
		/// <returns></returns>
		public string GetPermision()
		{
			return CacheUtil.GetCache<string>( "GLV_SYS_PERMISION" );
		}
	}
}