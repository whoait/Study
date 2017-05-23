//---------------------------------------------------------------------------
// System		: Seibi order
// Class Name	: DC1010Controller
// Overview		: Check user login information.
// Designer		: PhuongPD@FPT
// Programmer	: NamNTP1@FPT
// Created Date	: 2015/04/08
//---------------------------------------------------------------------------
namespace Gulliver.DoCol.Areas.Welcome.Controllers
{
	#region Using

	using System;
	using System.Web.Mvc;
	using System.Web.SessionState;

	using Gulliver.DoCol.BusinessServices.Common;
	using Gulliver.DoCol.Constants;
	using Gulliver.DoCol.Controllers;
	using Gulliver.DoCol.Entities.Common.DC1010Model;
	using Gulliver.DoCol.Library;
	using Gulliver.DoCol.UtilityServices;

	#endregion Using

	/// <summary>
	/// Check user login information.
	/// </summary>
	public class DC1010Controller : BaseController
	{
		#region Declare constants

		// H9020 HQ
		private const string H9020_MENU_HQ = "H9020MenuforHeadOffice";

		// H9020 SHOP
		private const string H9020_MENU_SHOP = "H9020MenuforShop";

		// H9020 Controller
		private const string H9020_CONTROLLER = "H9020";

		// H2020 Index
		private const string H2020_INDEX = "H2020Index";

		// H2020 Controller
		private const string H2020_CONTROLLER = "H2020";

		// parameter value for error.
		private const int CST_VAL_ERROR = -1;

		// parameter success value for SOS system.
		private const int CST_VAL_SUCCESS_SOS = 0;

		// parameter success value for eBoard system.
		private const int CST_VAL_SUCCESS_EBOARD = 2;

		// parameter success value for TAPS system.
		private const int CST_VAL_SUCCESS_TAPS = 1;

		#endregion Declare constants

		/// <summary>
		/// Set login information.
		/// </summary>
		/// <returns>Login DC1010 screen.</returns>
		[HttpGet]
        public ActionResult DC1010Index()
		{
			// 3. Return DC1010 view with default value.
            return this.View("DC1010Index");
		}

		/// <summary>
		/// Check user login into system.
		/// </summary>
		/// <param name="model">The user login information.</param>
		/// <returns>The H9020 view.</returns>
		[HttpPost]
        public ActionResult DC1010Login(DC1010InterfaceLoginModel model)
		{
			// remove all cache
			CacheUtil.RemoveAllCache();
			
			// 1. Input check.
			if (!ModelState.IsValid)
			{
				return this.View( model );
			}

			// Create new object get status login.
			DC1010CheckLoginModel objResultLogin = new DC1010CheckLoginModel();

			// Create new Service object to check login status.
			using (DC1010Services service = new DC1010Services())
			{
				// 2. Check login by user.
				objResultLogin = service.DC1010CheckLoginByMultiStatus( model );
				if (objResultLogin == null)
				{
					// Set error mesage into ViewBag.
					this.ViewBag.GetLoginFailed = UtilityServices.Utility.GetMessage( MessageCd.W0103 );

					// Return DC1010 page with old data.
					return this.View( model );
				}

				// 3. Save user login information into session common.
				base.CmnEntityModel.TempoCd = objResultLogin.TempoCd;
				base.CmnEntityModel.TempoName = objResultLogin.TempoName;
				base.CmnEntityModel.ShainNo = objResultLogin.ShainNo;
				base.CmnEntityModel.ShainName = objResultLogin.ShainName;

				CacheUtil.SaveCache( CacheKeys.CmnEntityModel, base.CmnEntityModel );

				// 4. Redirect to H9020 for Shop view.
				if (model.LoginMode)
				{
					return base.Redirect( H9020_MENU_SHOP, H9020_CONTROLLER );
				}

				// 5. Redirect to H9020 for HQ view.
				return base.Redirect( H9020_MENU_HQ, H9020_CONTROLLER );
			}
		}

		/// <summary>
		/// Logout
		/// </summary>
		/// <returns></returns>
		public ActionResult Logout()
		{
			CacheUtil.RemoveAllCache();
			return base.Redirect( "DC1010Index", "DC1010", new { Area = "Common" } );
		}

		/// <summary>
		/// Check user login by auto mode.
		/// </summary>
		/// <param name="entryLogin">The user login information.</param>
		/// <returns>The login status and goal page.</returns>
        //[HttpPost]
        //public RedirectResult DC1010AutoLoginSOS( DC1010LoginModel entryLogin )
        //{
        //    // remove all cache
        //    CacheUtil.RemoveAllCache();

        //    this.ControllerContext.HttpContext.Response.Headers.Add( "Access-Control-Allow-Origin", "*" );

        //    #region Logs
        //    //Log.SaveLogToFile( Log.LogLevel.INFO, "Autolog", "DungNH6", "", Request.UserHostAddress, "Thử nghiệm", "Autologin with method POST from other domain" );
        //    //if (!string.IsNullOrWhiteSpace( entryLogin.shainNo ) && !string.IsNullOrWhiteSpace( entryLogin.shainPassword ))
        //    //{
        //    //	Log.SaveLogToFile( Log.LogLevel.INFO, "=== ①SOS ===", "DungNH6", "", Request.UserHostAddress, "Param", "shainNo=" + entryLogin.shainNo + "; shainPassword=" + entryLogin.shainPassword );
        //    //}
        //    //else if (!string.IsNullOrWhiteSpace( entryLogin.shodan_kanri_no ) && !string.IsNullOrWhiteSpace( entryLogin.shodan_kanri_eda_no )
        //    //	 && !string.IsNullOrWhiteSpace( entryLogin.sharyo_order_no ))
        //    //{
        //    //	Log.SaveLogToFile( Log.LogLevel.INFO, "=== ③TAPS ===", "DungNH6", "", Request.UserHostAddress, "Param", "tenpo_cd=" + entryLogin.tenpo_cd + "; tenpo_pw=" + entryLogin.tenpo_pw + "; shain_cd=" + entryLogin.shain_cd + "; shain_pw=" + entryLogin.shain_pw + "; shodan_kanri_no=" + entryLogin.shodan_kanri_no + "; shodan_kanri_eda_no=" + entryLogin.shodan_kanri_eda_no + "; sharyo_order_no=" + entryLogin.sharyo_order_no + "; dn_shuppin_no=" + entryLogin.dn_shuppin_no + "; siire_no=" + entryLogin.siire_no + "; user_id=" + entryLogin.user_id + "; ordered_flg=" + entryLogin.ordered_flg + "; from_taps_hanbai=" + entryLogin.from_taps_hanbai );
        //    //}
        //    //else if (!string.IsNullOrWhiteSpace( entryLogin.tenpo_cd ) && !string.IsNullOrWhiteSpace( entryLogin.tenpo_pw )
        //    //		 && !string.IsNullOrWhiteSpace( entryLogin.shain_cd ) && !string.IsNullOrWhiteSpace( entryLogin.shain_pw ))
        //    //{
        //    //	Log.SaveLogToFile( Log.LogLevel.INFO, "=== ②eBoard ===", "DungNH6", "", Request.UserHostAddress, "Param", "tenpo_cd=" + entryLogin.tenpo_cd + "; tenpo_pw=" + entryLogin.tenpo_pw + "; shain_cd=" + entryLogin.shain_cd + "; shain_pw=" + entryLogin.shain_pw );
        //    //} 
        //    #endregion

        //    string newTabId = UriUtility.ConvertStringtoMD5( DateTime.Now.ToString() );
        //    string url = "";
        //    url = Url.Action(
        //                "NotAuthenticated",
        //                "Error",
        //                new { area = "Common", tabId = newTabId } );

        //    using (DC1010Services service = new DC1010Services())
        //    {
        //        // Create new object get status login.
        //        DC1010CheckLoginModel objResultLogin = new DC1010CheckLoginModel();

        //        // 1. Check login by user.
        //        int result = service.DC1010CheckLoginByMultiStatus( entryLogin, ref objResultLogin );

        //        if (objResultLogin != null)
        //        {
        //            // 3. Save user login information into session common.
        //            base.CmnEntityModel.TempoCd = objResultLogin.TempoCd;
        //            base.CmnEntityModel.TempoName = objResultLogin.TempoName;
        //            base.CmnEntityModel.ShainNo = objResultLogin.ShainNo;
        //            base.CmnEntityModel.ShainName = objResultLogin.ShainName;
        //            CacheUtil.SaveCache( CacheKeys.CmnEntityModel, base.CmnEntityModel );
        //        }

        //        // 1.1. In-case login error.
        //        if (result == CST_VAL_ERROR)
        //        {
        //            url = Url.Action(
        //                "NotPermission",
        //                "Error",
        //                new { area = "Common", tabId = newTabId });
        //        }

        //        if (result == CST_VAL_SUCCESS_SOS)
        //        {
        //            // 1.2. In-case login from SOS system sucessful.
        //            // Redirect to H9020 HQ view.
        //            url = Url.Action(
        //                H9020_MENU_HQ,
        //                H9020_CONTROLLER,
        //                new { area = "Common", tabId = newTabId, sessionID = Session.SessionID });
        //        }
        //    }

        //    return this.Redirect( url.Replace( "http:", "https:" ).Replace( ":8082", "" ) );
        //}
		
        //[HttpPost]
        //public RedirectResult DC1010AutoLoginEBoard( DC1010LoginModel entryLogin )
        //{
        //    // remove all cache
        //    CacheUtil.RemoveAllCache();

        //    this.ControllerContext.HttpContext.Response.Headers.Add( "Access-Control-Allow-Origin", "*" );
        //    string newTabId = UriUtility.ConvertStringtoMD5( DateTime.Now.ToString() );
        //    string url = "";
        //    url = Url.Action(
        //                "NotAuthenticated",
        //                "Error",
        //                new { area = "Common", tabId = newTabId } );

        //    using (DC1010Services service = new DC1010Services())
        //    {
        //        // Create new object get status login.
        //        DC1010CheckLoginModel objResultLogin = new DC1010CheckLoginModel();

        //        // 1. Check login by user.
        //        int result = service.DC1010CheckLoginByMultiStatus( entryLogin, ref objResultLogin );

        //        if (objResultLogin != null)
        //        {
        //            // 3. Save user login information into session common.
        //            base.CmnEntityModel.TempoCd = objResultLogin.TempoCd;
        //            base.CmnEntityModel.TempoName = objResultLogin.TempoName;
        //            base.CmnEntityModel.ShainNo = objResultLogin.ShainNo;
        //            base.CmnEntityModel.ShainName = objResultLogin.ShainName;
        //            CacheUtil.SaveCache( CacheKeys.CmnEntityModel, base.CmnEntityModel );
        //        }

        //        // 1.1. In-case login error.
        //        if (result == CST_VAL_ERROR)
        //        {
        //            url = Url.Action(
        //                "NotPermission",
        //                "Error",
        //                new { area = "Common", tabId = newTabId });
        //        }

        //        if (result == CST_VAL_SUCCESS_EBOARD)
        //        {
        //            // 1.3. In-case login from eBoard system sucessful.
        //            // Redirect to H9020 Shop view.
        //            url = Url.Action(
        //                H9020_MENU_SHOP,
        //                H9020_CONTROLLER,
        //                new { area = "Common", tabId = newTabId, sessionID = Session.SessionID });
        //        }
        //    }

        //    return this.Redirect( url.Replace( "http:", "https:" ).Replace( ":8082", "" ) );
        //}
		
        //[HttpPost]
        //public RedirectResult DC1010AutoLoginTap( DC1010LoginModel entryLogin )
        //{
        //    // remove all cache
        //    CacheUtil.RemoveAllCache();

        //    this.ControllerContext.HttpContext.Response.Headers.Add( "Access-Control-Allow-Origin", "*" );
        //    string newTabId = UriUtility.ConvertStringtoMD5( DateTime.Now.ToString() );
        //    string url = "";
        //    url = Url.Action(
        //                "NotAuthenticated",
        //                "Error",
        //                new { area = "Common", tabId = newTabId });

        //    using (DC1010Services service = new DC1010Services())
        //    {
        //        // Create new object get status login.
        //        DC1010CheckLoginModel objResultLogin = new DC1010CheckLoginModel();

        //        // 1. Check login by user.
        //        int result = service.DC1010CheckLoginByMultiStatus( entryLogin, ref objResultLogin );

        //        if (objResultLogin != null)
        //        {
        //            // 3. Save user login information into session common.
        //            base.CmnEntityModel.TempoCd = objResultLogin.TempoCd;
        //            base.CmnEntityModel.TempoName = objResultLogin.TempoName;
        //            base.CmnEntityModel.ShainNo = objResultLogin.ShainNo;
        //            base.CmnEntityModel.ShainName = objResultLogin.ShainName;
        //            CacheUtil.SaveCache( CacheKeys.CmnEntityModel, base.CmnEntityModel );
        //        }

        //        // 1.1. In-case login error.
        //        if (result == CST_VAL_ERROR)
        //        {
        //            url = Url.Action(
        //                "NotPermission",
        //                "Error",
        //                new { area = "Common", tabId = newTabId });
        //        }

        //        if (result == CST_VAL_SUCCESS_TAPS)
        //        {
        //            // 1.4. In-case login from TAPS system sucessful.
        //            // Redirect to H2010 view with parameter.
        //            url = Url.Action(
        //                            H2020_INDEX,
        //                            H2020_CONTROLLER,
        //                            new
        //                            {
        //                                area = "Order",
        //                                ShodanKanriNo = entryLogin.shodan_kanri_no,
        //                                ShodanKanriEdaNo = entryLogin.shodan_kanri_eda_no,
        //                                ShiireNo = entryLogin.siire_no,
        //                                OrderStatus = entryLogin.ordered_flg,
        //                                SharyoOrderNo = entryLogin.sharyo_order_no,
        //                                DnNo = entryLogin.dn_shuppin_no,
        //                                ScreenId = ScreenId.DC1010,
        //                                tabId = newTabId,
        //                                sessionID = Session.SessionID
        //                            });
        //        }

        //        return this.Redirect( url.Replace( "http:", "https:" ).Replace( ":8082", "" ) );
        //    }
        //}
	}
}