using Gulliver.DoCol.BusinessServices.DCW;
using Gulliver.DoCol.Controllers;
using Gulliver.DoCol.Entities.DCW.DCW003Model;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Gulliver.DoCol.WebReference;
using Gulliver.DoCol.ReportServices;
using System.Data.SqlClient;
using Gulliver.DoCol.UtilityServices;
using Gulliver.DoCol.Entities.Common;
using Gulliver.DoCol.Constants;
using Gulliver.DoCol.BusinessServices.Common;
using System.Web.Configuration;
using System.Text;
using System.Text.RegularExpressions;
namespace Gulliver.DoCol.Areas.DCW.Controllers
{
	public class DCW003Controller : BaseController
	{
        private int PageSize = int.Parse(ConfigurationManager.AppSettings["PageSize"]);
		private Dictionary<string, string> _contentType = new Dictionary<string, string>();

		public ActionResult DCW003Index( int mode, int check )
		{
			string lstError = string.Empty;
            string lstErrorExist = string.Empty;
			string lstNoMap = string.Empty;
			string lstImport = string.Empty;
			string lstDocControlNo = string.Empty;
			string messageContent = string.Empty;
			string messageType = string.Empty;
			int rowCount = 0;

			DCW003Model model = new DCW003Model();
			DCW003ConditionModel conditionModel = new DCW003ConditionModel();
			DCW003DetailModel detailModel = new DCW003DetailModel();
			List<DCW003Uketori> uketoriModel = new List<DCW003Uketori>();
			List<DCW003Result> resultModel = new List<DCW003Result>();
			DCW003ConditionModel cache = base.GetCache<DCW003ConditionModel>( CacheKeys.DCW003_CONDITION );

            if (cache == null)
            {
                conditionModel.PageIndex = DCW003Constant.DEFAULT_PAGE_INDEX;
                conditionModel.PageSize = PageSize;
                conditionModel.KeiCarFlg0 = NUMBER.NUM_0;
                conditionModel.KeiCarFlg1 = NUMBER.NUM_0;
                conditionModel.JishameiFlg = NUMBER.NUM_0;
                conditionModel.MasshoFlg = NUMBER.NUM_0;
                conditionModel.RadioType = NUMBER.NUM_1;
            }
            else {
                conditionModel = cache;
                mode = 0;
            }

			List<DCW003FuzokuhinMaster> lstFuzokuhinMaster = new List<DCW003FuzokuhinMaster>();

			using (DCW003Services services = new DCW003Services())
			{
				//Get label master fuzokuhin
				lstFuzokuhinMaster = services.DCW003GetFuzokuhinMaster();
				ViewBag.DocFuzokuhinMaster = lstFuzokuhinMaster;

				switch (mode)
				{

                    case 0:
                        {
                            conditionModel.ModeImport = 0;
                            services.DCW003Search(conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount);
                        }
                        break;
					//詳細条件で書類を検索する
					case 1:
						{
							conditionModel.ShohinType = DCW003Constant.SHOHIN_TYPE_DN;
							conditionModel.DocStatus102 = 1;
							conditionModel.AaDnSeiyakuDateStart = null;
							//conditionModel.AaDnSeiyakuDateEnd = DateTime.Now.AddDays( -1 );
                            ViewBag.Mode = 1;
                            //services.DCW003Search( conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount );
						}
						break;

					//本日発送予定の書類を検索する(普通車)
					case 2:
						{
							conditionModel.ShohinType = DCW003Constant.SHOHIN_TYPE_DN;
							conditionModel.DocStatus102 = 1;
							conditionModel.KeiCarFlg0 = NUMBER.NUM_1;
							//conditionModel.AaDnSeiyakuDateEnd = DateTime.Now.AddDays( -1 );
                            conditionModel.Mode = 2;
							services.DCW003Search( conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount );
						}
						break;

					//本日発送予定の書類を検索する(軽)
					case 3:
						{
							conditionModel.ShohinType = DCW003Constant.SHOHIN_TYPE_DN;
							conditionModel.DocStatus102 = 1;
							conditionModel.KeiCarFlg1 = NUMBER.NUM_1;
							//conditionModel.AaDnSeiyakuDateEnd = DateTime.Now.AddDays( -1 );
                            conditionModel.Mode = 3;
							services.DCW003Search( conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount );
						}
						break;
                    //本日発送予定の書類を検索する(AA)
                    case 4:
                        {
                            conditionModel.ShohinType = DCW003Constant.SHOHIN_TYPE_AA;
                            conditionModel.DocStatus102 = 1;
                            conditionModel.Mode = 4;
                            services.DCW003Search(conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount);
                        }
                        break;

					//棚卸し
					case 5:
						{
							conditionModel.DocStatus102 = 1;

							services.DCW003Search( conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount );
						}
						break;
                    //Import 1
                    #region Import1
                    case 6:
						{
							List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
							DataTable tblCsv = (DataTable)TempData["tblCsv"];
							if (tblCsv != null)
							{
								if (tblCsv.Rows.Count > 0)
								{
									for (int i = 0; i < tblCsv.Rows.Count; i++)
									{
										lstCsv.Add( new DCW003CsvModel
										{
											ID = i,
											RacFileNo = tblCsv.Rows[i][0].ToString(),
											KeiCarFlg = tblCsv.Rows[i][1].ToString(),
                                            TorokuNo = tblCsv.Rows[i][2].ToString().Replace("　", string.Empty).Normalize(NormalizationForm.FormKC),
											HyobanType = tblCsv.Rows[i][3].ToString(),
											ChassisNo = tblCsv.Rows[i][4].ToString(),
											GendokiKatashiki = tblCsv.Rows[i][5].ToString(),
											ReportType = tblCsv.Rows[i][6].ToString(),
										} );
									}
									if (check == 0)
									{
										conditionModel.ModeImport = 1;
                                        services.DCW003ImportCsv(lstCsv, out lstError, out lstErrorExist, out lstNoMap, out lstImport, out lstDocControlNo);
										Utility.GetMessage( MessageCd.I0010,
                                                            SubStringList(lstImport), SubStringList(lstError), SubStringList(lstErrorExist), SubStringList(lstNoMap),
															out messageType,
															out messageContent );
										ViewBag.contentMsgI0010 = messageContent;
										ViewBag.typeMsgI0010 = messageType;

                                        base.SaveCache(CacheKeys.DCW003_LIST_DOC_CONTROL_NO, lstDocControlNo);

										if (!string.IsNullOrEmpty( lstDocControlNo ))
										{
											lstDocControlNo = lstDocControlNo.Substring( 1 );
											services.DCW003GetListImport( lstCsv,lstDocControlNo, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize,
																			out resultModel, out uketoriModel, out rowCount );
										}
									}
									else
									{
										conditionModel.ModeImport = 2;
										services.DCW003GetDocControlExist( lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 1,
																			out resultModel, out uketoriModel, out lstImport, out rowCount ); 

										Utility.GetMessage( MessageCd.I0010,
                                                            SubStringList(lstImport), string.Empty, string.Empty, string.Empty,
															out messageType,
															out messageContent );
										ViewBag.contentMsgI0010 = messageContent;
										ViewBag.typeMsgI0010 = messageType;
									}
								}
								else
								{
									return ReturnResult();
								}
							}
						}
						break;
                    #endregion
                    #region Import2
                    case 7:
						{
							conditionModel.ModeImport = 3;
							List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
							DataTable tblCsv = (DataTable)TempData["tblCsv"];
							if (tblCsv != null)
							{
								if (tblCsv.Rows.Count > 0)
								{
									for (int i = 0; i < tblCsv.Rows.Count; i++)
									{
										lstCsv.Add( new DCW003CsvModel
										{
											ID =i,
											KeiCarFlg = tblCsv.Rows[i][0].ToString(),
                                            TorokuNo = tblCsv.Rows[i][1].ToString().Replace("　", string.Empty).Normalize(NormalizationForm.FormKC),
											HyobanType = tblCsv.Rows[i][2].ToString(),
											ChassisNo = tblCsv.Rows[i][3].ToString(),
											GendokiKatashiki = tblCsv.Rows[i][4].ToString(),
											ReportType = tblCsv.Rows[i][5].ToString(),
										} );
									}

									services.DCW003GetDocControlExist( lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 2,
																		out resultModel, out uketoriModel, out lstImport, out rowCount );
                                    TempData["tblCsv"] = tblCsv;
								}
							}
						}
						break;
                    #endregion
                    #region Import3
                    case 8:
						{
							conditionModel.ModeImport = 3;
							List<DCW003RFID> lstCsv = new List<DCW003RFID>();
							DataTable tblCsv = (DataTable)TempData["tblCsv"];
							if (tblCsv != null)
							{
								if (tblCsv.Rows.Count > 0)
								{
									for (int i = 0; i < tblCsv.Rows.Count; i++)
									{
										lstCsv.Add( new DCW003RFID
										{
											ID = i,
											RFIDKey = tblCsv.Rows[i][0].ToString(),
										} );
									}

									services.DCW003GetDocControlMaster( lstCsv, lstFuzokuhinMaster,conditionModel.PageIndex, conditionModel.PageSize,
                                        out resultModel, out uketoriModel,out rowCount );
                                    //uketoriModel = services.DCW003Get
								}
							}
                            TempData["tblCsv"] = tblCsv;
						}
						break;
                    #endregion
                    #region Import4
                    case 9:
						{
							conditionModel.ModeImport = 4;
							List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
							DataTable tblCsv = (DataTable)TempData["tblCsv"];
							if (tblCsv != null)
							{
								if (tblCsv.Rows.Count > 0)
								{
									for (int i = 0; i < tblCsv.Rows.Count; i++)
									{
										if (tblCsv.Rows[i][5].ToString() == Import4.Type2)
										{
											tblCsv.Rows[i][5] = "101";
										}
										else if (tblCsv.Rows[i][5].ToString() == Import4.Type1)
										{
											tblCsv.Rows[i][5] = "201";
										}
										lstCsv.Add( new DCW003CsvModel
										{
											ID = i,
											IraiDate = tblCsv.Rows[i][0].ToString(),
											ShopCd = tblCsv.Rows[i][1].ToString(),
											GenshaLocation = tblCsv.Rows[i][2].ToString(),
											CarName = tblCsv.Rows[i][3].ToString(),
											ChassisNo = tblCsv.Rows[i][4].ToString(),
											JMType = tblCsv.Rows[i][5].ToString(),
											Note = tblCsv.Rows[i][6].ToString(),
										} );
									}

									services.DCW003GetDocControlExist( lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 3,
																		out resultModel, out uketoriModel, out lstImport, out rowCount );

									if (resultModel.Count >0)
									{
										services.DCWOO3InserJishameiMassho( resultModel, lstCsv );
									}		
								}
							}
                            TempData["tblCsv"] = tblCsv;
						}
						break;
                    #endregion
                    #region Import5
                    case 10:
                        {
                            conditionModel.ModeImport = 5;
                            List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
                            DataTable tblCsv = (DataTable)TempData["tblCsv"];
                            if (tblCsv != null)
                            {
                                if (tblCsv.Rows.Count > 0)
                                {
                                    for (int i = 0; i < tblCsv.Rows.Count; i++)
                                    {
                                        lstCsv.Add(new DCW003CsvModel
                                        {
                                            ID = i,
                                            HensoIraiDate = tblCsv.Rows[i][0].ToString(),
                                            ShopCd = tblCsv.Rows[i][1].ToString(),
                                            ShopName = tblCsv.Rows[i][2].ToString(),
                                            TantoshaName = tblCsv.Rows[i][3].ToString(),
                                            CarName = tblCsv.Rows[i][4].ToString(),
                                            ChassisNo = tblCsv.Rows[i][5].ToString(),
                                            ShiireSaki = tblCsv.Rows[i][6].ToString(),
                                            TorokuNo = tblCsv.Rows[i][7].ToString(),
                                            HensoRiyu = tblCsv.Rows[i][8].ToString(),
                                            Note = tblCsv.Rows[i][9].ToString(),
                                            JishameiYouhi = tblCsv.Rows[i][10].ToString()
                                        });
                                    }

                                    services.DCW003GetHenSoIfExist(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize,
                                                                          out resultModel, out uketoriModel, out lstImport, out rowCount);
                                                
                                    //services.DCW003GetDocControlExist(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 5,
                                    //                                    out resultModel, out uketoriModel, out lstImport, out rowCount);
                                    //if (resultModel.Count > 0) {
                                    //    services.DCW003ImportHensoIF(lstCsv);
                                    //}
                                    TempData["tblCsv"] = tblCsv;
                                }
                            }
                        }
                        break;
                    #endregion
                }
			}
            
            conditionModel.TotalRow = resultModel.Count != 0 ? resultModel[0].RowCount: 0;
            if (conditionModel.TotalRow == 0 && mode != 6 && mode != 1) {
                Utility.GetMessage(MessageCd.I0003, string.Empty, out messageType, out messageContent);
                ViewBag.typeMsgI0010 = messageType;
                ViewBag.contentMsgI0010 = messageContent;
            }
			detailModel.UketoriModel = uketoriModel;
			detailModel.ResultModel = resultModel;
			model.Condition = conditionModel;
			model.Detail = detailModel;
            conditionModel.Mode = mode;
			base.SaveCache( CacheKeys.DCW003_CONDITION, conditionModel );
			InitialDropDownList();

			ViewBag.SearchCondition = model.Condition;
			return View( model );
		}

        private string SubStringList(string lst)
        {
            if (!string.IsNullOrEmpty(lst))
            {
                lst = lst.Substring(1);
            }   
            return lst;
        }

		private void InitialDropDownList()
		{
			List<DCW003DropDownModel> dropMassho = new List<DCW003DropDownModel>();
			List<DCW003DropDownModel> dropJishamei = new List<DCW003DropDownModel>();
			List<DCW003DropDownModel> dropDocStatus = new List<DCW003DropDownModel>();
			List<DCW003DropDownModel> dropYear = new List<DCW003DropDownModel>();
            DCW003ConditionModel cache = base.GetCache<DCW003ConditionModel>(CacheKeys.DCW003_CONDITION);
			using (DCW003Services services = new DCW003Services())
			{
				dropDocStatus = services.DCW003GetMasterDocStatus();
				dropYear = services.DCW003GetMasterYear();
			}
			//YEAR
			ViewBag.DropYear = dropYear;

			//DOC STATUS
            if (cache.ModeImport == 1 || cache.ModeImport == 2)
            {
                ViewBag.DropDocStatus = dropDocStatus;
            }
            else {
                dropDocStatus.RemoveAt(0);
                ViewBag.DropDocStatus = dropDocStatus;
            }
			//MASSHO
			dropMassho.Insert( 0, new DCW003DropDownModel { Value = "0", Text = "継続" } );
			dropMassho.Insert( 1, new DCW003DropDownModel { Value = "1", Text = "抹消" } );
			ViewBag.DropMassho = dropMassho;

			//JISHAMEI
			dropJishamei.Insert( 0, new DCW003DropDownModel { Value = "0", Text = "" } );
			dropJishamei.Insert( 1, new DCW003DropDownModel { Value = "1", Text = "自社名済" } );
			ViewBag.DropJishamei = dropJishamei;
		}

		public ActionResult DCW003Paging( CmnPagingModel cmnPagingModel )
		{
			DCW003ConditionModel conditionModel = base.GetCache<DCW003ConditionModel>( CacheKeys.DCW003_CONDITION );
            String lst = GetCache<String>(CacheKeys.DCW003_LIST_DOC_CONTROL_NO);
			List<DCW003FuzokuhinMaster> lstFuzokuhinMaster = new List<DCW003FuzokuhinMaster>();
			string typeMsg = string.Empty;
			string errorMsg = string.Empty;
			int rowCount = 0;
			conditionModel.PageIndex = cmnPagingModel.PageIndex;
			conditionModel.PageSize = cmnPagingModel.PageSize;
            conditionModel.PageBegin = cmnPagingModel.PageBegin;
            conditionModel.PageEnd = cmnPagingModel.PageEnd;

			DCW003DetailModel detailModel = new DCW003DetailModel();
			List<DCW003Result> resultModel = new List<DCW003Result>();
			List<DCW003Uketori> uketoriModel = new List<DCW003Uketori>();
            
			using (DCW003Services services = new DCW003Services())
			{
				lstFuzokuhinMaster = services.DCW003GetFuzokuhinMaster();
				ViewBag.DocFuzokuhinMaster = lstFuzokuhinMaster;

                switch (conditionModel.ModeImport) {
                    case 1:
                        {
                            List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
                            DataTable tblCsv = (DataTable)TempData["tblCsv"];
                            if (!string.IsNullOrEmpty(lst))
                            {
                                for (int i = 0; i < tblCsv.Rows.Count; i++)
                                {
                                    lstCsv.Add(new DCW003CsvModel
                                    {
                                        ID = i,
                                        RacFileNo = tblCsv.Rows[i][0].ToString(),
                                        KeiCarFlg = tblCsv.Rows[i][1].ToString(),
                                        TorokuNo = tblCsv.Rows[i][2].ToString().Replace("　", string.Empty).Normalize(NormalizationForm.FormKC),
                                        HyobanType = tblCsv.Rows[i][3].ToString(),
                                        ChassisNo = tblCsv.Rows[i][4].ToString(),
                                        GendokiKatashiki = tblCsv.Rows[i][5].ToString(),
                                        ReportType = tblCsv.Rows[i][6].ToString(),
                                    });
                                }

                                lst = lst.Substring(1);
                                services.DCW003GetListImport(lstCsv ,lst, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize,
                                                                out resultModel, out uketoriModel, out rowCount);

                            }
                        } 
                        break;

                    case 2: 
                        {
                            List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
                            DataTable tblCsv = (DataTable)TempData["tblCsv"];
                            if (tblCsv != null)
                            {
                                if (tblCsv.Rows.Count > 0)
                                {
                                    for (int i = 0; i < tblCsv.Rows.Count; i++)
                                    {
                                        lstCsv.Add(new DCW003CsvModel
                                        {
                                            ID = i,
                                            RacFileNo = tblCsv.Rows[i][0].ToString(),
                                            KeiCarFlg = tblCsv.Rows[i][1].ToString(),
                                            TorokuNo = tblCsv.Rows[i][2].ToString().Replace("　", string.Empty).Normalize(NormalizationForm.FormKC),
                                            HyobanType = tblCsv.Rows[i][3].ToString(),
                                            ChassisNo = tblCsv.Rows[i][4].ToString(),
                                            GendokiKatashiki = tblCsv.Rows[i][5].ToString(),
                                            ReportType = tblCsv.Rows[i][6].ToString(),
                                        });
                                    }

                                    string lstImport = string.Empty;

                                    services.DCW003GetDocControlExist(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 1,
                                                                                    out resultModel, out uketoriModel, out lstImport, out rowCount);
                                }
                            }
                            else {
                                base.CmnEntityModel.ErrorMsgCd = MessageCd.I0003;
                                return ReturnResult();
                            }
                        } 
                        break;

                    case 3:
                        {
                            if (conditionModel.Mode == 7)
                            {
                                List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
                                DataTable tblCsv = (DataTable)TempData["tblCsv"];
                                if (tblCsv != null)
                                {
                                    if (tblCsv.Rows.Count > 0)
                                    {
                                        for (int i = 0; i < tblCsv.Rows.Count; i++)
                                        {
                                            lstCsv.Add(new DCW003CsvModel
                                            {
                                                ID = i,
                                                KeiCarFlg = tblCsv.Rows[i][0].ToString(),
                                                TorokuNo = tblCsv.Rows[i][1].ToString().Replace("　", string.Empty).Normalize(NormalizationForm.FormKC),
                                                HyobanType = tblCsv.Rows[i][2].ToString(),
                                                ChassisNo = tblCsv.Rows[i][3].ToString(),
                                                GendokiKatashiki = tblCsv.Rows[i][4].ToString(),
                                                ReportType = tblCsv.Rows[i][5].ToString(),
                                            });
                                        }
                                        string lstImport = string.Empty;
                                        services.DCW003GetDocControlExist(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 2,
                                                                            out resultModel, out uketoriModel, out lstImport, out rowCount);
                                    }
                                }
                                TempData["tblCsv"] = tblCsv;
                            }
                            else {
                                List<DCW003RFID> lstCsv = new List<DCW003RFID>();
                                DataTable tblCsv = (DataTable)TempData["tblCsv"];
                                if (tblCsv != null)
                                {
                                    if (tblCsv.Rows.Count > 0)
                                    {
                                        for (int i = 0; i < tblCsv.Rows.Count; i++)
                                        {
                                            lstCsv.Add(new DCW003RFID
                                            {
                                                ID = i,
                                                RFIDKey = tblCsv.Rows[i][0].ToString(),
                                            });
                                        }

                                        services.DCW003GetDocControlMaster(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize,
                                        out resultModel, out uketoriModel, out rowCount);
                                    }
                                }
                                TempData["tblCsv"] = tblCsv;
                            }
                        } break;

                    case 4: 
                        {
                            List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
                            DataTable tblCsv = (DataTable)TempData["tblCsv"];
                            if (tblCsv != null)
                            {
                                if (tblCsv.Rows.Count > 0)
                                {
                                    for (int i = 0; i < tblCsv.Rows.Count; i++)
                                    {
                                        if (tblCsv.Rows[i][5].ToString() == Import4.Type2)
                                        {
                                            tblCsv.Rows[i][5] = "101";
                                        }
                                        else if (tblCsv.Rows[i][5].ToString() == Import4.Type1)
                                        {
                                            tblCsv.Rows[i][5] = "201";
                                        }
                                        lstCsv.Add(new DCW003CsvModel
                                        {
                                            ID = i,
                                            IraiDate = tblCsv.Rows[i][0].ToString(),
                                            ShopCd = tblCsv.Rows[i][1].ToString(),
                                            GenshaLocation = tblCsv.Rows[i][2].ToString(),
                                            CarName = tblCsv.Rows[i][3].ToString(),
                                            ChassisNo = tblCsv.Rows[i][4].ToString(),
                                            JMType = tblCsv.Rows[i][5].ToString(),
                                            Note = tblCsv.Rows[i][6].ToString(),
                                        });
                                    }

                                    string lstImport = string.Empty;
                                    services.DCW003GetDocControlExist(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize, 3,
                                                                        out resultModel, out uketoriModel, out lstImport, out rowCount);

                                    if (resultModel.Count > 0)
                                    {
                                        services.DCWOO3InserJishameiMassho(resultModel, lstCsv);
                                    }
                                }
                            }
                            TempData["tblCsv"] = tblCsv;
                        } break;

                    case 5:
                        {
                            List<DCW003CsvModel> lstCsv = new List<DCW003CsvModel>();
                            DataTable tblCsv = (DataTable)TempData["tblCsv"];
                            if (tblCsv != null)
                            {
                                if (tblCsv.Rows.Count > 0)
                                {
                                    for (int i = 0; i < tblCsv.Rows.Count; i++)
                                    {
                                        lstCsv.Add(new DCW003CsvModel
                                        {
                                            ID = i,
                                            HensoIraiDate = tblCsv.Rows[i][0].ToString(),
                                            ShopCd = tblCsv.Rows[i][1].ToString(),
                                            ShopName = tblCsv.Rows[i][2].ToString(),
                                            TantoshaName = tblCsv.Rows[i][3].ToString(),
                                            CarName = tblCsv.Rows[i][4].ToString(),
                                            ChassisNo = tblCsv.Rows[i][5].ToString(),
                                            ShiireSaki = tblCsv.Rows[i][6].ToString(),
                                            TorokuNo = tblCsv.Rows[i][7].ToString(),
                                            HensoRiyu = tblCsv.Rows[i][8].ToString(),
                                            Note = tblCsv.Rows[i][9].ToString(),
                                            JishameiYouhi = tblCsv.Rows[i][10].ToString()
                                        });
                                    }
                                    string lstImport = string.Empty;
                                    services.DCW003GetHenSoIfExist(lstCsv, lstFuzokuhinMaster, conditionModel.PageIndex, conditionModel.PageSize,
                                                                           out resultModel, out uketoriModel, out lstImport, out rowCount);
                                    TempData["tblCsv"] = tblCsv;
                                }
                            }
                        } break;
                    
                    default: services.DCW003Search(conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount); break;
                }


				//services.DCW003Search( conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount );
			}

			detailModel.ResultModel = resultModel;
			detailModel.UketoriModel = uketoriModel;
            base.SaveCache(CacheKeys.DCW003_CONDITION,conditionModel);
			InitialDropDownList();
			ViewBag.SearchCondition = conditionModel;
            ViewBag.contentMsgI0010 = string.Empty;
            ViewBag.typeMsgI0010 = string.Empty;
			return View( "_DCW003Result", detailModel );
		}

		public ActionResult DCW003Search( DCW003ConditionModel conditionModel )
		{
            DCW003ConditionModel cache = base.GetCache<DCW003ConditionModel>(CacheKeys.DCW003_CONDITION);
			List<DCW003FuzokuhinMaster> lstFuzokuhinMaster = new List<DCW003FuzokuhinMaster>();
            base.RemoveCache("DCW003ListDocControlNo");
			string typeMsg = string.Empty;
			string contentMsg = string.Empty;
			int rowCount = 0;
			conditionModel.PageIndex = DCW003Constant.DEFAULT_PAGE_INDEX;
			conditionModel.PageSize = PageSize;
			DCW003DetailModel detailModel = new DCW003DetailModel();
			List<DCW003Result> resultModel = new List<DCW003Result>();
			List<DCW003Uketori> uketoriModel = new List<DCW003Uketori>();
			using (DCW003Services services = new DCW003Services())
			{
				lstFuzokuhinMaster = services.DCW003GetFuzokuhinMaster();
				ViewBag.DocFuzokuhinMaster = lstFuzokuhinMaster;

				services.DCW003Search( conditionModel, lstFuzokuhinMaster, out resultModel, out uketoriModel, out rowCount );
				if (resultModel.Count == 0)
				{
					UtilityServices.Utility.GetMessage( MessageCd.I0003,
												string.Empty,
												out typeMsg,
												out contentMsg );

					this.ViewBag.typeMsgI0001 = typeMsg;
					this.ViewBag.contentMsgI0001 = contentMsg;
				}
			}
			if (conditionModel == null)
			{
				conditionModel.PageIndex = DCW003Constant.DEFAULT_PAGE_INDEX;
				conditionModel.PageSize = PageSize;
				conditionModel.TotalRow = rowCount;
			}
            conditionModel.TotalRow = resultModel.Count != 0 ? resultModel[0].RowCount : 0;
			base.SaveCache( CacheKeys.DCW003_CONDITION, conditionModel );
			detailModel.ResultModel = resultModel;
			detailModel.UketoriModel = uketoriModel;
			InitialDropDownList();
			ViewBag.SearchCondition = conditionModel;
			return View( "_DCW003Result", detailModel );
		}
		//Edit fix bug 66 HoaVV start
		public JsonResult DCW003Update( DCW003Result resultModel )
		{
            using (DCW003Services services = new DCW003Services())
            {
                DCW003ListReturnUpdate listReturnUpdate = services.DCW003Update(resultModel);
                if (listReturnUpdate != null && listReturnUpdate.DnSeiyakuDate!=null)
                {
                    listReturnUpdate.DnSeiyakuDateValue = listReturnUpdate.DnSeiyakuDate.Value.Date.ToString("yyyy/MM/dd");
                }
                string messageContent = string.Empty;
                string messageClass = string.Empty;
                string messageCd = MessageCd.I0001;
                string messageReplace = string.Empty;
                bool isSuccess = true;
                if (!String.IsNullOrEmpty(base.CmnEntityModel.ErrorMsgCd))
                {
                    messageCd = base.CmnEntityModel.ErrorMsgCd;
                    messageReplace = base.CmnEntityModel.ErrorMsgReplaceString;
                    isSuccess = false;
                }

                UtilityServices.Utility.GetMessage(messageCd,
                    string.Empty,
                    out messageClass,
                    out messageContent);
                return this.Json(new { Success = isSuccess, MessageClass = messageClass, Message = messageContent, ListReturnUpdate = listReturnUpdate }, JsonRequestBehavior.AllowGet);
            }
           // return View("_Tab1.cshtml", resultModel);
		}
		//Edit fix bug 66 HoaVV end
		public ActionResult DCW003UpdateAll( List<DCW003Result> resultModel )
		{
			if (resultModel != null)
			{
				List<DCW003Update> lst = new List<DCW003Update>();
				foreach (var item in resultModel)
				{
                    if (item.JishameiKanryoNyukoDate != null || item.MasshoKanryoNyukoDate!= null)
                    {
                        item.ShoruiLimitDate = null;
                    }
					lst.Add( new DCW003Update
					{
						DocControlNo = item.DocControlNo,
						UriageShuppinTorokuNo = item.UriageShuppinnTorokuNo,
						MasshoFlg = item.MasshoFlg,
						JishameiFlg = item.JishameiFlg,
						DocStatus = item.DocStatus,
						DocNyukoDate = item.DocNyukoDate,
						DocShukkoDate = item.DocShukkoDate,
						JishameiIraiShukkoDate = item.JishameiIraiShukkoDate,
						JishameiKanryoNyukoDate = item.JishameiKanryoNyukoDate,
						MasshoIraiShukkoDate = item.MasshoIraiShukkoDate,
						MasshoKanryoNyukoDate = item.MasshoKanryoNyukoDate,
                        ShoruiLimitDate = item.ShoruiLimitDate,
                        ShakenLimitDate = item.ShakenLimitDate,
						Memo = item.Memo
					} );
				}

				using (DCW003Services services = new DCW003Services())
				{
					services.DCW003UpdateAll( lst );
				}
				return ReturnResult();
			}
			else
			{
				base.CmnEntityModel.ErrorMsgCd = MessageCd.W0001;
				return ReturnResult();
			}
		}

		public ActionResult DCW003SendAutoSearch( List<DCW003Result> resultModel )
		{
			string lstError = string.Empty;
			string lstSuccess = string.Empty;
			if (resultModel != null)
			{
				List<DCW003Update> lst = new List<DCW003Update>();

				foreach (var item in resultModel)
				{
					lst.Add( new DCW003Update
					{
						RackNo = item.RacNo,
						FileNo = item.FileNo,
						ChassisNo = item.ChassisNo
					} );
				}

				using (DCW003Services services = new DCW003Services())
				{
					services.DCW003SendAutoSearch( lst, out lstSuccess, out lstError );
				}

				return ReturnListResult( SubStringList(lstSuccess), SubStringList(lstError) );
			}
			else
			{
				base.CmnEntityModel.ErrorMsgCd = "W0001";
				return ReturnResult();
			}
		}

		public ActionResult DCW003Register( List<DCW003Uketori> uketoriModel )
		{
            bool updateFlg = false;
            foreach (var obj in uketoriModel)
            {
                if (obj.CheckRegister == 1)
                {
                    updateFlg = true;
                    break;
                }
            }
            if (updateFlg)
            {
                using (DCW003Services services = new DCW003Services())
                {
                    services.DCW003Register(uketoriModel);
                }
                return ReturnResult();
            }
            else
            {
                base.CmnEntityModel.ErrorMsgCd = "W0001";
                return ReturnResult();
            }
		}
        //Add HoaVV P2 start
        public ActionResult DCW003SendToGHQ(List<DCW003Uketori> uketoriModel)
        {
            bool updateFlg = false;
            foreach (var obj in uketoriModel)
            {
                if (obj.CheckRegister == 1)
                {
                    updateFlg = true;
                    break;
                }
            }
            if (updateFlg)
            {
                using (DCW003Services services = new DCW003Services())
                {
                    services.DCW003SendToGHQ(uketoriModel);
                }
                return ReturnResult();
            }
            else
            {
                base.CmnEntityModel.ErrorMsgCd = "W0001";
                return ReturnResult();
            }
        }


        public ActionResult DCW003ExportCSVLinkGHQ(List<DCW003Uketori> uketoriModel)
        {

            if (uketoriModel != null)
            {
                using (DCW003Services services = new DCW003Services())
                {
                    services.DCW003ExportCSVLinkGHQ(uketoriModel);
                }
                return ReturnResult();
            }
            else
            {
                base.CmnEntityModel.ErrorMsgCd = "W0001";
                return ReturnResult();
            }
        }
        public ActionResult DCW003ExportCSVLinkGHQNewTab(List<DCW003Uketori> uketoriModel) 
        {
            bool updateFlg = false;
            foreach (var obj in uketoriModel)
            {
                if (obj.CheckRegister == 1)
                {
                    updateFlg = true;
                    break;
                }
            }
            if (updateFlg)
            {
                DataReportsClients getDataReportClient = new DataReportsClients();

                MemoryStream stream = new MemoryStream();
                DataTable table1 = new DataTable();
                DataTable table2 = new DataTable();
                table1.Columns.Add("車輌番号", typeof(string));
                table1.Columns.Add("登録年", typeof(string));
                table1.Columns.Add("登録月", typeof(string));
                table1.Columns.Add("登録日", typeof(string));
                table1.Columns.Add("車台番号", typeof(string));
                table1.Columns.Add("備考欄", typeof(string));

                table2.Columns.Add("自動車登録番号又は車両番号", typeof(string));
                table2.Columns.Add("登録年", typeof(string));
                table2.Columns.Add("登録月", typeof(string));
                table2.Columns.Add("登録日", typeof(string));
                table2.Columns.Add("車台番号", typeof(string));
                table2.Columns.Add("乗車定員", typeof(string));
                table2.Columns.Add("総排気量又は定格出力", typeof(string));
                table2.Columns.Add("備考欄", typeof(string));
                using (DCW003Services services = new DCW003Services())
                {
                    string Japan_Year = "";
                    List<DCW003JapanYear> LstJapan_Year = new List<DCW003JapanYear>();
                    LstJapan_Year = services.DCW003GetJapanYear();
                for (int i = 0; i < uketoriModel.Count; i++)
                {
                    if (uketoriModel[i].KeiCarFlg == "1")
                    {
                        if (uketoriModel[i].JishameiKanryoNyukoDate == null)
                        {
                            table2.Rows.Add(uketoriModel[i].TorokuNo, "", "", "", uketoriModel[i].ChassisNo, uketoriModel[i].JoshaTeiinNum, uketoriModel[i].CcName.ToString(),"");
                        }
                        else
                        {
                                foreach (var obj in LstJapan_Year)
                                {
                                    if (obj.Year == uketoriModel[i].JishameiKanryoNyukoDate.Value.Year.ToString())
                                    {
                                        Japan_Year = obj.JapanYear;
                                        break;
                                    }
                                }
                            table2.Rows.Add(uketoriModel[i].TorokuNo, Japan_Year, uketoriModel[i].JishameiKanryoNyukoDate.Value.Month, uketoriModel[i].JishameiKanryoNyukoDate.Value.Day, uketoriModel[i].ChassisNo, uketoriModel[i].JoshaTeiinNum, uketoriModel[i].CcName.ToString(), "");
                            Japan_Year = "";
                        }
                    }
                    else
                    {                      
                        if (uketoriModel[i].JishameiKanryoNyukoDate == null)
                        {
                            table1.Rows.Add(uketoriModel[i].TorokuNo, "", "", "", uketoriModel[i].ChassisNo,"");
                        }
                        else
                        {
                                foreach (var obj in LstJapan_Year)
                                {
                                    if (obj.Year == uketoriModel[i].JishameiKanryoNyukoDate.Value.Year.ToString())
                                    {
                                        Japan_Year = obj.JapanYear;
                                        break;
                                    }
                                }

                            table1.Rows.Add(uketoriModel[i].TorokuNo, Japan_Year, uketoriModel[i].JishameiKanryoNyukoDate.Value.Month, uketoriModel[i].JishameiKanryoNyukoDate.Value.Day, uketoriModel[i].ChassisNo, "");
                            Japan_Year = "";
                        }
                    }
                }
            }
                stream = getDataReportClient.ExportCSV(table1, table2);
                string attachment = "attachment; filename= " + DateTime.Now.ToString("yyyyMMdd") + "_meihen.zip";
                Response.AddHeader("content-disposition", attachment);
                Response.ContentType = "application/zip";
                Response.BinaryWrite(stream.ToArray());
                Response.Flush();
                Response.Clear();
                Response.End();
                stream.Close();
                return new EmptyResult();
            }
            else
            {
                base.CmnEntityModel.ErrorMsgCd = "W0001";
                return ReturnResult();
            }
        
        }

        //Add HoaVV P2 end
		public ActionResult PrintPage( List<DCW003Result> resultModel)
		{
            
			if (resultModel != null)
			{
                string ReportID = resultModel[0].ReportID;
				DataTable table = new DataTable();
				MemoryStream stream = new MemoryStream();
				#region getFileReport
				// コンテントタイプの辞書を作成
				_contentType.Clear();
				_contentType.Add( ".fcp", "application/x-fmfcp" );
				_contentType.Add( ".fcx", "application/x-fmfcx" );

				_contentType.Add( ".dat", "text/plain" );
				_contentType.Add( ".xml", "application/x-fmdat+xml" );
				_contentType.Add( ".csv", "text/csv" );
				_contentType.Add( ".tsv", "text/tab-separated-value" );
				_contentType.Add( ".fcq", "application/x-fmfcq" );

				_contentType.Add( ".bmp", "image/x-bmp" );
				_contentType.Add( ".emf", "image/x-emf" );
				_contentType.Add( ".wmf", "image/x-wmf" );
				_contentType.Add( ".tif", "image/tiff" );
				_contentType.Add( ".jpg", "image/jpeg" );
				_contentType.Add( ".gif", "image/gif" );
				_contentType.Add( ".png", "image/png" );

				_contentType.Add( ".dev", "application/XmlReadMode-fmfcp" );

				_contentType.Add( ".fmcsm", "Application/x-fmcsm" );
				_contentType.Add( ".fmcsmd", "Application/x-fmcsmd" );

				FMWebService service = new FMWebService();
				service.Timeout = 1200 * 1000;
				service.Url = ConfigurationManager.AppSettings["WebReference.FMWebService"];

				FMWSRequest request = new FMWSRequest();
				FMWSKeyValue[] headers = new FMWSKeyValue[0];
				request.headers = headers;

				//リクエストパラメータの生成と、リクエストへの登録
				List<FMWSKeyValue> parameters = new List<FMWSKeyValue>();
				FMWSKeyValue param = new FMWSKeyValue();

				List<FMWSData> datas = new List<FMWSData>();

				System.Text.Encoding enc = System.Text.Encoding.GetEncoding( "Shift_JIS" );
				string fpath = Server.MapPath( @"~/iwfm/" ) + "iwfm_" + DateTime.Now.ToString( "yMMdd_HHmmss" ) + ".dat";
				System.IO.StreamWriter sr = new System.IO.StreamWriter( fpath, false, enc );

				///// 開始
				sr.WriteLine( @"[Control Section]" );
				sr.WriteLine( @"VERSION=7.2" );
				sr.WriteLine( @"OPTION=FIELDATTR" );
				sr.WriteLine( @";" );

				// Get data for report
				DataTable dataReport = new DataTable();
				DataReportsClients getDataReportClient = new DataReportsClients();
				//DataTable table = new DataTable();
				table.Columns.Add( "Item", typeof( string ) );
                table.Columns.Add("ID", typeof(string));
				//for (int i = 0; i < DocControlNo.Length; i++)
				//	table.Rows.Add( DocControlNo[i].ToString() );
                for (int i = 0; i < resultModel.Count; i++) {
                    table.Rows.Add(resultModel[i].DocControlNo,i);
                }

                //foreach (var item in resultModel)
                //{
                //    table.Rows.Add( item.DocControlNo );
                //}

				var pList = new SqlParameter( "@list", SqlDbType.Structured );
				pList.TypeName = "dbo.StringList";
				pList.Value = table;
                switch (ReportID) {
                    case "RD0020":
                        {
                            param.value = DCW003Constant.DEF_RD0020_FILE;
                            dataReport = getDataReportClient.ExportPDFRD0020(table);
                            if (dataReport.Rows.Count > 0)
                            {
                                param.key = "fm-formfilename";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-outputtype";
                                param.value = "pdf";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-action";
                                param.value = "view";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-target";
                                param.value = "client";
                                parameters.Add(param);
                                request.parameters = parameters.ToArray();

                                foreach (DataRow dr in dataReport.Rows)
                                {
                                    #region create data file RD0020.DAT
                                    sr.WriteLine(@"[Body Data Section]");
                                    sr.WriteLine(string.Format(@"<line1>={0}", dr["SHOP_CD"].ToString()));
                                    sr.WriteLine(string.Format(@"<line1_1>={0}", dr["TEMPO_NAME"].ToString()));
                                    sr.WriteLine(string.Format(@"<line1_2>={0}", "在庫"));
                                    sr.WriteLine(string.Format(@"<line2>={0}", "車庫証明・自社名依頼申請書"));
                                    sr.WriteLine(string.Format(@"<line3>={0}", "店舗コード"));
                                    sr.WriteLine(string.Format(@"<line3_1>={0}", dr["DJ_SHOPCD"].ToString()));
                                    sr.WriteLine(string.Format(@"<line4>={0}", "店舗名"));
                                    sr.WriteLine(string.Format(@"<line4_1>={0}", dr["TEMPO_NAME_DJ"].ToString()));
                                    sr.WriteLine(string.Format(@"<line5>={0}", "車名"));
                                    sr.WriteLine(string.Format(@"<line5_1>={0}", dr["CAR_NAME"].ToString()));
                                    sr.WriteLine(string.Format(@"<line6>={0}", "車台番号"));
                                    sr.WriteLine(string.Format(@"<line6_1>={0}", dr["CHASSIS_NO"].ToString()));
                                    sr.WriteLine(string.Format(@"<line7>={0}", "仕入番号"));
                                    sr.WriteLine(string.Format(@"<line7_1>={0}", dr["SHIIRE_NO"].ToString()));
                                    sr.WriteLine(string.Format(@"<line8>={0}", "車庫証明を取得し、自社名変をお願い致します"));
                                    sr.WriteLine(string.Format(@"<line9>={0}", "自社名終了後は車検原本をこの申請書と一緒に幕張オフィスDNチームにお送り下さい。"));
                                    sr.WriteLine(string.Format(@"<line10>={0}", dr["DN"].ToString()));
                                    sr.WriteLine(string.Format(@"<line11>={0}", "J-NET TEL"));
                                    sr.WriteLine(string.Format(@"<line11_1>={0}", dr["TEL"].ToString()));
                                    sr.WriteLine(string.Format(@"<line12>={0}", "          FAX"));
                                    sr.WriteLine(string.Format(@"<line12_1>={0}", dr["FAX"].ToString()));
                                    sr.WriteLine(string.Format(@"<line13>={0}", "管理番号: "));
                                    sr.WriteLine(string.Format(@"<line13_1>={0}", dr["CONTROL_NUMBER"].ToString()));
                                    sr.WriteLine(string.Format(@"<symbol>={0}", "※"));
                                    sr.WriteLine(string.Format(@"<symbol_1>={0}", "※"));

                                    sr.WriteLine(string.Format(@"[Form Section]"));
                                    sr.WriteLine(string.Format(@"NEXTPAGE"));
                                    sr.WriteLine(string.Format(@";"));
                                    #endregion
                                }
                            }
                            else {
                                base.CmnEntityModel.ErrorMsgCd = MessageCd.I0013;
                                return ReturnResult();
                            }
                            break;
                        }
                    case "RD0010":
                        {
                            param.value = DCW003Constant.DEF_RD0010_FILE;
                            dataReport = getDataReportClient.ExportPDFRD0010(table);
                            if (dataReport.Rows.Count > 0)
                            {
                                param.key = "fm-formfilename";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-outputtype";
                                param.value = "pdf";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-action";
                                param.value = "view";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-target";
                                param.value = "client";
                                parameters.Add(param);
                                request.parameters = parameters.ToArray();

                                foreach (DataRow dr in dataReport.Rows)
                                {
                                    #region create data file RD0010.DAT
                                    sr.WriteLine(@"[Body Data Section]");
                                    sr.WriteLine(string.Format(@"<line1>={0}", "幕張オフィス書類チーム"));
                                    sr.WriteLine(string.Format(@"<line2>={0}", "登録書類返却用紙"));
                                    sr.WriteLine(string.Format(@"<line3>={0}", "店舗コード"));
                                    sr.WriteLine(string.Format(@"<line3_1>={0}", dr["ShopCd"].ToString()));
                                    sr.WriteLine(string.Format(@"<line4>={0}", "店舗名"));
                                    sr.WriteLine(string.Format(@"<line4_1>={0}", dr["ShopName"].ToString()));
                                    sr.WriteLine(string.Format(@"<line5>={0}", "車名"));
                                    sr.WriteLine(string.Format(@"<line5_1>={0}", dr["CarName"].ToString()));
                                    sr.WriteLine(string.Format(@"<line6>={0}", "車台番号"));
                                    sr.WriteLine(string.Format(@"<line6_1>={0}", dr["ChassisNo"].ToString()));
                                    sr.WriteLine(string.Format(@"<line7>={0}", "DN 番号"));
                                    sr.WriteLine(string.Format(@"<line7_1>={0}", dr["TorokuNo"].ToString()));
                                    sr.WriteLine(string.Format(@"<line8>={0}", "返送理由"));
                                    sr.WriteLine(string.Format(@"<line8_1>={0}", dr["HensoRiyu"].ToString()));
                                    sr.WriteLine(string.Format(@"<line9>={0}", "備考欄"));
                                    sr.WriteLine(string.Format(@"<line9_1>={0}", dr["Note"].ToString()));
                                    sr.WriteLine(string.Format(@"<line10>={0}", "担当"));
                                    sr.WriteLine(string.Format(@"<line10_1>={0}", dr["TantoshaName"].ToString()));
                                    sr.WriteLine(string.Format(@"<line11>={0}", "使用の本拠"));
                                    sr.WriteLine(string.Format(@"<line11_1>={0}", dr["Jishamei"].ToString()));
                                    sr.WriteLine(string.Format(@"<line12>={0}", "※"));
                                    sr.WriteLine(string.Format(@"<line12_1>={0}", "自社名する場合の謄本は店舗で申請してください"));
                                    sr.WriteLine(string.Format(@"<line13>={0}", dr["DN"].ToString()));
                                    sr.WriteLine(string.Format(@"<line14>={0}", "J-NET TEL"));
                                    sr.WriteLine(string.Format(@"<line14_1>={0}", dr["TEL"].ToString()));
                                    sr.WriteLine(string.Format(@"<line15>={0}", "          FAX"));
                                    sr.WriteLine(string.Format(@"<line15_1>={0}", dr["FAX"].ToString()));

                                    sr.WriteLine(string.Format(@"[Form Section]"));
                                    sr.WriteLine(string.Format(@"NEXTPAGE"));
                                    sr.WriteLine(string.Format(@";"));
                                    #endregion
                                }
                            }
                            else
                            {
                                base.CmnEntityModel.ErrorMsgCd = MessageCd.I0013;
                                return ReturnResult();
                            }
                            break;
                        }

                    case "RD0030":
                        {
                            param.value = DCW003Constant.DEF_RD0030_FILE;
                            dataReport = getDataReportClient.ExportPDFRD0030(table);
                            if (dataReport.Rows.Count > 0)
                            {
                                param.key = "fm-formfilename";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-outputtype";
                                param.value = "pdf";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-action";
                                param.value = "view";
                                parameters.Add(param);
                                param = new FMWSKeyValue();
                                param.key = "fm-target";
                                param.value = "client";
                                parameters.Add(param);
                                request.parameters = parameters.ToArray();

                                foreach (DataRow dr in dataReport.Rows)
                                {
                                    #region create data file RD0030.DAT
                                    sr.WriteLine(@"[Body Data Section]");
                                    sr.WriteLine(string.Format(@"<line1>={0}", dr["AA_KAISAI_KAISU"].ToString()));
                                    sr.WriteLine(string.Format(@"<line2>={0}", dr["AA_KAISAI_MONTH"].ToString()));
                                    sr.WriteLine(string.Format(@"<line2_1>={0}", dr["AA_KAISAI_DATE"].ToString()));
                                    sr.WriteLine(string.Format(@"<line2_2>={0}", dr["AA_SHUPPIN_NO"].ToString()));
                                    sr.WriteLine(string.Format(@"<line2_3>={0}", dr["URIAGE_AA_KAIJO_CD"].ToString()));
                                    sr.WriteLine(string.Format(@"<line3>={0}", dr["CAR_NAME"].ToString()));
                                    sr.WriteLine(string.Format(@"<line3_1>={0}", dr["CHASSIS_NO"].ToString()));

                                    sr.WriteLine(string.Format(@"[Form Section]"));
                                    sr.WriteLine(string.Format(@"NEXTPAGE"));
                                    sr.WriteLine(string.Format(@";"));
                                    #endregion
                                }
                            }
                            else
                            {
                                base.CmnEntityModel.ErrorMsgCd = MessageCd.I0013;
                                return ReturnResult();
                            }
                            break;
                        }

                    default:
                        {
                            base.CmnEntityModel.ErrorMsgCd = "W0001";
                            return ReturnResult();
                        }
                }

                #region code cu RD0020
                //if (dataReport.Rows.Count > 0)
                //{
                //    param.key = "fm-formfilename";
                //    parameters.Add( param );
                //    param = new FMWSKeyValue();
                //    param.key = "fm-outputtype";
                //    param.value = "pdf";
                //    parameters.Add( param );
                //    param = new FMWSKeyValue();
                //    param.key = "fm-action";
                //    param.value = "view";
                //    parameters.Add( param );
                //    param = new FMWSKeyValue();
                //    param.key = "fm-target";
                //    param.value = "client";
                //    parameters.Add( param );
                //    request.parameters = parameters.ToArray();

                //    foreach (DataRow dr in dataReport.Rows)
                //    {
                //        #region create data file RD0020.DAT
                //            sr.WriteLine( @"[Body Data Section]" );
                //            sr.WriteLine( string.Format( @"<line1>={0}", dr["SHOP_CD"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line1_1>={0}", dr["TEMPO_NAME"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line1_2>={0}", "在庫" ) );
                //            sr.WriteLine( string.Format( @"<line2>={0}", "車庫証明・自社名依頼申請書" ) );
                //            sr.WriteLine( string.Format( @"<line3>={0}", "店舗コード" ) );
                //            sr.WriteLine( string.Format( @"<line3_1>={0}", dr["DJ_SHOPCD"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line4>={0}", "店舗名" ) );
                //            sr.WriteLine( string.Format( @"<line4_1>={0}", dr["TEMPO_NAME"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line5>={0}", "車名" ) );
                //            sr.WriteLine( string.Format( @"<line5_1>={0}", dr["CAR_NAME"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line6>={0}", "車台番号" ) );
                //            sr.WriteLine( string.Format( @"<line6_1>={0}", dr["CHASSIS_NO"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line7>={0}", "仕入番号" ) );
                //            sr.WriteLine( string.Format( @"<line7_1>={0}", dr["SHIIRE_NO"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line8>={0}", "車庫証明を取得し、自社名変をお願い致します" ) );
                //            sr.WriteLine( string.Format( @"<line9>={0}", "自社名終了後は車検原本をこの申請書と一緒に幕張オフィスDNチームにお送り下さい。" ) );
                //            sr.WriteLine( string.Format( @"<line10>={0}", dr["DN"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line11>={0}", "J-NET TEL" ) );
                //            sr.WriteLine( string.Format( @"<line11_1>={0}", dr["TEL"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line12>={0}", "          FAX" ) );
                //            sr.WriteLine( string.Format( @"<line12_1>={0}", dr["TEL"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<line13>={0}", "管理番号: " ) );
                //            sr.WriteLine( string.Format( @"<line13_1>={0}", dr["CONTROL_NUMBER"].ToString() ) );
                //            sr.WriteLine( string.Format( @"<symbol>={0}", "※" ) );
                //            sr.WriteLine( string.Format( @"<symbol_1>={0}", "※" ) );

                //            sr.WriteLine( string.Format( @"[Form Section]" ) );
                //            sr.WriteLine( string.Format( @"NEXTPAGE" ) );
                //            sr.WriteLine( string.Format( @";" ) );
                //            #endregion				
                //    }
                //}
                #endregion

                sr.Close();

				//DATファイルの登録
				FMWSData datdata = new FMWSData();
				datdata.content = System.IO.File.ReadAllBytes( fpath );
				datdata.contentName = Path.GetFileName( fpath );
				datdata.contentType = _contentType[Path.GetExtension( fpath ).ToLower()];
				datas.Add( datdata );

				request.attachments = datas.ToArray();

				FMWSResponse response = service.overlay( request );
				Dictionary<string, List<String>> headerMap = new Dictionary<string, List<string>>();
				foreach (FMWSKeyValue header in response.headers)
				{
					List<string> list;
					if (!headerMap.ContainsKey( header.key ))
					{
						list = new List<string>();
						headerMap.Add( header.key, list );
					}
					else
					{
						list = headerMap[header.key];
					}
					list.Add( header.value );
				}
				string serviceStatus = headerMap["x-service-status"][0];//.ElementAt(0);
				//ステータスの確認
				if (serviceStatus != "200")
				{
					//string serviceMessage = headerMap["x-service-message"][0];//.ElementAt(0);
					//throw new Exception("overlay failure: " + serviceMessage);
					//Connect service khong thanh cong
					base.CmnEntityModel.ErrorMsgCd = "E0009";
					return ReturnResult();
				}

				Response.ClearContent();
				Response.Buffer = true;

				foreach (FMWSData attachment in response.attachments)
				{

					//IEの場合はファイル名をURLエンコードする
					String file = attachment.contentName;
					if (Request.Browser.Browser == "IE")
					{
						file = HttpUtility.UrlEncode( file );
					}
					Response.AddHeader( "Content-Disposition", "inline;filename=Report" + DateTime.Now.ToString( "yyyyMMdd" ) + ".pdf" );
					Response.ContentType = "application/pdf";
					Response.BinaryWrite( attachment.content );
					break;
				}

				Response.Flush();
				Response.End();
				return View( "_DCW003ViewPrintPage" );
				#endregion
			}
			else
			{
				base.CmnEntityModel.ErrorMsgCd = "W0001";
				return ReturnResult();
			}
		}

		public ActionResult OutputCsv( List<DCW003Result> resultModel )
		{
			if (resultModel != null)
			{
				DataReportsClients getDataReportClient = new DataReportsClients();
				MemoryStream stream = new MemoryStream();
				DataTable table = new DataTable();
				table.Columns.Add( "ファイルNO", typeof( string ) );
				//table.Rows.Add( "1", "123" );
				//table.Rows.Add( "2", "123" );
				foreach (var item in resultModel)
				{
                    table.Rows.Add(item.RacNo+item.FileNo);
				}
				stream = getDataReportClient.ExportCSV( table );


				string attachment = "attachment; filename= " + DateTime.Now.ToString( "yyyyMMddhhmmss" ) + "_TO_HD_CHECK.csv";
				Response.AddHeader( "content-disposition", attachment );
				Response.ContentType = "text/csv";
				//Response.AddHeader("ファイルNO");
				Response.BinaryWrite( stream.ToArray() );
				Response.Flush();
				stream.Close();

				return new EmptyResult();
			}
			else
			{
				base.CmnEntityModel.ErrorMsgCd = "W0001";
				return ReturnResult();
			}
		}
        //Add fix bug 85 HoaVV start

        public ActionResult DCW003OutputCsvCR(List<DCW003Result> resultModel)
        {
            if (resultModel != null)
            {
                DataReportsClients getDataReportClient = new DataReportsClients();
                MemoryStream stream = new MemoryStream();
                DataTable tableExport = new DataTable();
                tableExport.Columns.Add("車台番号", typeof(string));
                tableExport.Columns.Add("書類ステータス", typeof(string));
                tableExport.Columns.Add("仕入DN出品番号", typeof(string));
                tableExport.Columns.Add("売上DN出品番号", typeof(string));
                tableExport.Columns.Add("出品店情報(店舗コード)", typeof(string));
                tableExport.Columns.Add("出品店情報(店舗名)", typeof(string));
                tableExport.Columns.Add("落札店情報(店舗コード)", typeof(string));
                tableExport.Columns.Add("落札店情報(店舗名)", typeof(string));
                tableExport.Columns.Add("仕入AA会場", typeof(string));
                tableExport.Columns.Add("売上AA会場", typeof(string));
                tableExport.Columns.Add("AA開催日", typeof(string));
                tableExport.Columns.Add("AA番号", typeof(string));
                tableExport.Columns.Add("DN成約日", typeof(string));
                tableExport.Columns.Add("仕入番号", typeof(string));
                tableExport.Columns.Add("年式", typeof(string));
                tableExport.Columns.Add("メーカー", typeof(string));
                tableExport.Columns.Add("車名", typeof(string));
                tableExport.Columns.Add("グレード", typeof(string));
                tableExport.Columns.Add("型式", typeof(string));
                tableExport.Columns.Add("車両区分", typeof(string));
                tableExport.Columns.Add("登録ナンバー", typeof(string));
                tableExport.Columns.Add("車検満了日", typeof(string));
                tableExport.Columns.Add("書類有効期限", typeof(string));
                tableExport.Columns.Add("自社名区分", typeof(string));
                tableExport.Columns.Add("書類区分", typeof(string));
                tableExport.Columns.Add("書類入庫日", typeof(string));
                tableExport.Columns.Add("書類出庫日", typeof(string));
                tableExport.Columns.Add("自社名依頼日", typeof(string));
                tableExport.Columns.Add("自社名完了日", typeof(string));
                tableExport.Columns.Add("抹消依頼日", typeof(string));
                tableExport.Columns.Add("抹消完了日", typeof(string));
                tableExport.Columns.Add("ファイル番号", typeof(string));
                tableExport.Columns.Add("メモ", typeof(string));

                foreach (var item in resultModel)
                {
                    string[] ShopName = item.ShopName.Split(' ');
                    string[] RakusatsuShopName = item.RakusatsuShopName.Split(' ');
                    string KeiCarFlg= "";
                    string MasshoFlg = "";
                    string JishameiFlg = "";
                    string DocStatus = "";
                    //Set value KeiCarFlg
                    if(item.KeiCarFlg== "0")
                    {
                        KeiCarFlg = "普通車";
                    }else if(item.KeiCarFlg== "1")
                    {
                        KeiCarFlg = "軽";
                    }
                    //Set value MashoFlg
                    if (item.MasshoFlg == "0")
                    {
                        MasshoFlg = "継続";
                    }
                    else if (item.MasshoFlg == "1")
                    {
                        MasshoFlg = "抹消";
                    }
                    //Set value JishameiFlg
                    if (item.JishameiFlg == "0")
                    {
                        JishameiFlg = "";
                    }
                    else if (item.JishameiFlg == "1")
                    {
                        JishameiFlg = "自社名済";
                    }
                    //Set value Docstatus
                    switch (item.DocStatus)
                    {
                        case "102":
                            DocStatus = "保管中";
                            break;
                        case "103":
                            DocStatus = "自社名中";
                            break;
                        case "104":
                            DocStatus = "自社名中";
                            break;
                        case "105":
                            DocStatus = "発送済";
                            break;
                    }
                    string AaKaisaiDate = (item.AaKaisaiDate == null) ? "" : item.AaKaisaiDate.Value.ToString("yyyy/MM/dd");
                    string DnSeiyakuDate = (item.DnSeiyakuDate == null) ? "" : item.DnSeiyakuDate.Value.ToString("yyyy/MM/dd");
                    string ShakenLimitDate = (item.ShakenLimitDate == null) ? "" : item.ShakenLimitDate.Value.ToString("yyyy/MM/dd");
                    string ShoruiLimitDate = (item.ShoruiLimitDate == null) ? "" : item.ShoruiLimitDate.Value.ToString("yyyy/MM/dd");
                    string DocNyukoDate = (item.DocNyukoDate == null) ? "" : item.DocNyukoDate.Value.ToString("yyyy/MM/dd");
                    string DocShukkoDate = (item.DocShukkoDate == null) ? "" : item.DocShukkoDate.Value.ToString("yyyy/MM/dd");
                    string JishameiIraiShukkoDate = (item.JishameiIraiShukkoDate == null) ? "" : item.JishameiIraiShukkoDate.Value.ToString("yyyy/MM/dd");
                    string JishameiKanryoNyukoDate = (item.JishameiKanryoNyukoDate == null) ? "" : item.JishameiKanryoNyukoDate.Value.ToString("yyyy/MM/dd");
                    string MasshoIraiShukkoDate = (item.MasshoIraiShukkoDate == null) ? "" : item.MasshoIraiShukkoDate.Value.ToString("yyyy/MM/dd");
                    string MasshoKanryoNyukoDate = (item.MasshoKanryoNyukoDate == null) ? "" : item.MasshoKanryoNyukoDate.Value.ToString("yyyy/MM/dd");
                    string FileNo = item.RacNo + item.FileNo;
                    ///Add value to CSV
                    tableExport.Rows.Add(item.ChassisNo, DocStatus, item.ShiireShuppinnTorokuNo, item.UriageShuppinnTorokuNo,
                                   ShopName[0], ShopName[1], RakusatsuShopName[0], RakusatsuShopName[1],
                                   item.ShiireAaKaijo, item.UriageAaKaijo, AaKaisaiDate, item.AaShuppinNo,
                                   DnSeiyakuDate, item.ShiireNo, item.Nenshiki, item.MakerName,
                                   item.CarName, item.GradeName, item.Katashiki, KeiCarFlg,
                                   item.TorokuNo, ShakenLimitDate, ShoruiLimitDate, JishameiFlg,
                                   MasshoFlg, DocNyukoDate, DocShukkoDate, JishameiIraiShukkoDate, JishameiKanryoNyukoDate,
                                   MasshoIraiShukkoDate, MasshoKanryoNyukoDate, FileNo, item.Memo);
                }
                stream = getDataReportClient.ExportCSVCR(tableExport);
                string attachment = "attachment; filename= " + DateTime.Now.ToString("yyyyMMdd") + "_書類管理検索結果.csv";
                Response.AddHeader("content-disposition", attachment);
                Response.ContentType = "text/csv";
                //Response.AddHeader("ファイルNO");
                Response.BinaryWrite(stream.ToArray());
                Response.Flush();
                stream.Close();

                return new EmptyResult();
            }
            else
            {
                base.CmnEntityModel.ErrorMsgCd = "W0001";
                return ReturnResult();
            }
        }
        //Add fix bug 85 HoaVV end

		//Add fix bug 66 HoaVV end
        public ActionResult DCW003CheckInputTorokuno(string UriageShuppinnTorokuNo, string DocControlNo)
        {
            using (DCW003Services services = new DCW003Services())
            {
                services.DCW003CheckInputTorokuno(UriageShuppinnTorokuNo, DocControlNo);
            }
            return ReturnResult();
        
        }
		//Add fix bug 66 HoaVV end
		private JsonResult ReturnResult()
		{
			string messageContent = string.Empty;
			string messageClass = string.Empty;
			string messageCd = MessageCd.I0001;
			string messageReplace = string.Empty;
			bool isSuccess = true;
			if (!String.IsNullOrEmpty( base.CmnEntityModel.ErrorMsgCd ))
			{
				messageCd = base.CmnEntityModel.ErrorMsgCd;
				messageReplace = base.CmnEntityModel.ErrorMsgReplaceString;
				isSuccess = false;
			}

			UtilityServices.Utility.GetMessage( messageCd,
				string.Empty,
				out messageClass,
				out messageContent );
			return this.Json( new { Success = isSuccess, MessageClass = messageClass, Message = messageContent }, JsonRequestBehavior.AllowGet );
		}

		private JsonResult ReturnListResult( string lstSuccess, string lstError )
		{
			string messageContent = string.Empty;
			string messageClass = string.Empty;
			string messageCd = MessageCd.I0011;
			string messageReplace = string.Empty;
			bool isSuccess = true;
			if (!String.IsNullOrEmpty( base.CmnEntityModel.ErrorMsgCd ))
			{
				messageCd = base.CmnEntityModel.ErrorMsgCd;
				messageReplace = base.CmnEntityModel.ErrorMsgReplaceString;
				isSuccess = false;
			}

			UtilityServices.Utility.GetMessage( messageCd,
				lstSuccess, lstError,
				out messageClass,
				out messageContent );

			return this.Json( new { Success = isSuccess, MessageClass = messageClass, Message = messageContent }, JsonRequestBehavior.AllowGet );
		}
	}
}
