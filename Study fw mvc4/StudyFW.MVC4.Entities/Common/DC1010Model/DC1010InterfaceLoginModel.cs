//---------------------------------------------------------------------------
// System		: Seibi order
// Class Name	: DC1010InterfaceLoginModel
// Overview		: Get user login information.
// Designer		: PhuongPD@FPT
// Programmer	: NamNTP1@FPT
// Created Date	: 2015/04/08
//---------------------------------------------------------------------------
namespace StudyFW.MVC4.Entities.Common.DC1010Model
{
	#region Using

	using StudyFW.MVC4.Constants;
	using StudyFW.MVC4.Constants.Resources;
	using StudyFW.MVC4.DataValidation;

	#endregion Using

	/// <summary>
	/// Get user login information.
	/// </summary>
	public class DC1010InterfaceLoginModel
	{
		/// <summary>
		/// Login mode.
		/// </summary>
		public bool LoginMode { get; set; }

		/// <summary>
		/// Store code used for login direct.
		/// </summary>
		[EXRequiredIfConstraint( "LoginMode", true, MessageCd.W0001, typeof( DC1010 ), "lblAPSStoreNo" )]
		[EXAlphaNumberic( MessageCd.W0002, typeof( DC1010 ), "tempoCdAlphanumericRequired" )]
		public string TempoCd { get; set; }

		/// <summary>
		/// Store password used for login direct.
		/// </summary>
		[EXRequiredIfConstraint( "LoginMode", true, MessageCd.W0001, typeof( DC1010 ), "lblPassword_Store" )]
		[EXAlphaNumberic( MessageCd.W0002, typeof( DC1010 ), "passwordAlphanumericRequired" )]
		public string Password { get; set; }

		/// <summary>
		/// Employee code used for login direct.
		/// </summary>
		[EXRequired( MessageCd.W0001, typeof( DC1010 ), "lblGHRStaffNo" )]
		[EXAlphaNumberic( MessageCd.W0002, typeof( DC1010 ), "shainNoAlphanumericRequired" )]
		public string ShainNo { get; set; }

		/// <summary>
		/// Employee password used for login direct.
		/// </summary>
		[EXRequired( MessageCd.W0001, typeof( DC1010 ), "lblPassword_Staff" )]
		[EXAlphaNumberic( MessageCd.W0002, typeof( DC1010 ), "pswAlphanumericRequired" )]
		public string Psw { get; set; }

		/// <summary>
		/// Login mode.
		/// </summary>
		public short FlagMode { get; set; }
	}
}