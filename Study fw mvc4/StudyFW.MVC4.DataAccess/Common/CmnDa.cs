namespace StudyFW.MVC4.DataAccess.Common
{
	#region using

	using System;
	using System.Collections.Generic;
	using System.Data;
	using System.Web.Mvc;
    using StudyFW.MVC4.Constants;
    using StudyFW.MVC4.DataAccess.Framework;
    using StudyFW.MVC4.Entities;
    using StudyFW.MVC4.Entities.Common;

	#endregion using

	/// <summary>
	/// Common data access
	/// </summary>
	public class CmnDa : StudyFW.MVC4.DataAccess.BaseDa
	{
		public void GetSuggestion<T>( string textPattern, int maxResult, out List<T> listSuggest, string storeName ) where T : new()
		{
			using (var dbManager = new DBManager( storeName ))
			{
				dbManager.Add( SysStoreName.para_MaxResult, maxResult );
				dbManager.Add( SysStoreName.para_TextPattern, textPattern );

				DataTable dt = dbManager.GetDataTable();
				listSuggest = EntityHelper<T>.GetListObject( dt );
			}
		}
	}
}