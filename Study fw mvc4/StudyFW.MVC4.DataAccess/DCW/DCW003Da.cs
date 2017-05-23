using StudyFW.MVC4.Constants;
using StudyFW.MVC4.DataAccess.Framework;
using StudyFW.MVC4.Entities;
using StudyFW.MVC4.Entities.DCW.DCW003Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace StudyFW.MVC4.DataAccess.DCW
{
	public class DCW003Da : BaseDa
	{
		/// <summary>
		/// Get master Fuzokuhin
		/// </summary>
		/// <returns></returns>
		public List<DCW003FuzokuhinMaster> DCW003GetMasterFuzokuhin()
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_MASTER_FUZOKUHIN ))
			{
				DataTable tableResult = DbManager.GetDataTable();

				return Entities.EntityHelper<DCW003FuzokuhinMaster>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Search with condition
		/// </summary>
		/// <param name="searchConditions"></param>
		/// <returns></returns>
		public List<DCW003Result> DCW003SearchCondition( DCW003ConditionModel searchConditions, out int rowCount )
		{
			DataTable tblTorokuNo = new DataTable();
			tblTorokuNo.Columns.Add( "TorokuNo", typeof( string ) );
			if (!string.IsNullOrWhiteSpace(searchConditions.ShuppinnTorokuNo))
			{
				string[] lstTorokuNo = searchConditions.ShuppinnTorokuNo.Split( ',' );
				foreach (var item in lstTorokuNo)
				{
					if (!string.IsNullOrWhiteSpace(item))
					{
						if (item.Trim().Length<=8)
						{
							DataRow row = tblTorokuNo.NewRow();
							row["TorokuNo"] = item.Trim();
							tblTorokuNo.Rows.Add( row );
						}			
					}			
				}
			}

            DataTable tblChassisNo = new DataTable();
            tblChassisNo.Columns.Add("ChassisNo", typeof(string));
            if (!string.IsNullOrWhiteSpace(searchConditions.ChassisNo))
            {
                string[] lstChassisNo = searchConditions.ChassisNo.Split(',');
                foreach (var item in lstChassisNo)
                {
                    if (!string.IsNullOrWhiteSpace(item))
                    {
                        if (item.Trim().Length <= 25)
                        {
                            DataRow row = tblChassisNo.NewRow();
                            row["ChassisNo"] = item.Trim();
                            tblChassisNo.Rows.Add(row);
                        }
                    }
                }

            }

			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_SEARCH_CONDITION ))
			{
				DbManager.Add( DWC003StoreName.PARAM_SHUPPINN_TOROKUNO, searchConditions.ShuppinnTorokuNo );
				DbManager.Add( DWC003StoreName.PARAM_LIST_TOROKU_NO, SqlDbType.Structured, tblTorokuNo );
                DbManager.Add(DWC003StoreName.PARAM_LIST_CHASSIS_NO, SqlDbType.Structured, tblChassisNo);
				DbManager.Add( DWC003StoreName.PARAM_CHASSIS_NO, searchConditions.ChassisNo );
				DbManager.Add( DWC003StoreName.PARAM_RADIO_TYPE, searchConditions.RadioType );
				DbManager.Add( DWC003StoreName.PARAM_SHOHIN_TYPE, searchConditions.ShohinType );
				DbManager.Add( DWC003StoreName.PARAM_SHOP_CD, searchConditions.ShopCd );
				DbManager.Add( DWC003StoreName.PARAM_SHOP_NAME, searchConditions.ShopName );
				DbManager.Add( DWC003StoreName.PARAM_RAKUSATSU_SHOP_CD, searchConditions.RakusatsuShopCd );
				DbManager.Add( DWC003StoreName.PARAM_RAKUSATSU_SHOP_NAME, searchConditions.RakusatsuShopName );
				DbManager.Add( DWC003StoreName.PARAM_DOC_STATUS_102, searchConditions.DocStatus102 );
				DbManager.Add( DWC003StoreName.PARAM_DOC_STATUS_103, searchConditions.DocStatus103 );
				DbManager.Add( DWC003StoreName.PARAM_DOC_STATUS_104, searchConditions.DocStatus104 );
				DbManager.Add( DWC003StoreName.PARAM_DOC_STATUS_105, searchConditions.DocStatus105 );
				DbManager.Add( DWC003StoreName.PARAM_FILE_NO, searchConditions.FileNo );
				DbManager.Add( DWC003StoreName.PARAM_KEICAR_0_FLG, searchConditions.KeiCarFlg0 );
				DbManager.Add( DWC003StoreName.PARAM_KEICAR_1_FLG, searchConditions.KeiCarFlg1 );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_FLG, searchConditions.JishameiFlg );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_FLG, searchConditions.MasshoFlg );
				DbManager.Add( DWC003StoreName.PARAM_AA_DN_DATE_START, searchConditions.AaDnSeiyakuDateStart );
				DbManager.Add( DWC003StoreName.PARAM_AA_DN_DATE_END, searchConditions.AaDnSeiyakuDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_SHORUI_LIMIT_DATE_START, searchConditions.ShoruiLimitDateStart );
				DbManager.Add( DWC003StoreName.PARAM_SHORUI_LIMIT_DATE_END, searchConditions.ShoruiLimitDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_DOC_NYUKO_DATE_START, searchConditions.DocNyukoDateStart );
				DbManager.Add( DWC003StoreName.PARAM_DOC_NYUKO_DATE_END, searchConditions.DocNyukoDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_DOC_SHUKKO_DATE_START, searchConditions.DocShukkoDateStart );
				DbManager.Add( DWC003StoreName.PARAM_DOC_SHUKKO_DATE_END, searchConditions.DocShukkoDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_IRAI_SHUKKO_DATE_START, searchConditions.JishameiIraiShukkoDateStart );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_IRAI_SHUKKO_DATE_END, searchConditions.JishameiIraiShukkoDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_KANRYO_NYUKO_DATE_START, searchConditions.JishameiKanryoNyukoDateStart );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_KANRYO_NYUKO_DATE_END, searchConditions.JishameiKanryoNyukoDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_IRAI_SHUKKO_DATE_START, searchConditions.MasshoIraiShukkoDateStart );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_IRAI_SHUKKO_DATE_END, searchConditions.MasshoIraiShukkoDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_KANRYO_NYUKO_DATE_START, searchConditions.MasshoKanryoNyukoDateStart );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_KANRYO_NYUKO_DATE_END, searchConditions.MasshoKanryoNyukoDateEnd );
				DbManager.Add( DWC003StoreName.PARAM_SHAKEN_LIMIT_DATE_START, searchConditions.ShakenLimitDateStart );
				DbManager.Add( DWC003StoreName.PARAM_SHAKEN_LIMIT_DATE_END, searchConditions.ShakenLimitDateEnd );
                //Add HoaVV fix bug CR 84 start
                DbManager.Add(DWC003StoreName.IS_CANSEL_FLG, searchConditions.IsCanselflg);
                DbManager.Add(DWC003StoreName.NO_CANSEL_FLG, searchConditions.NoCanselflg);
                //Add HoaVV fix bug CR 84 end
                //DbManager.Add(DWC003StoreName.PARAM_DOCUMENT_NORMAL_CAR, searchConditions.DocumentNomalCar);
                //DbManager.Add(DWC003StoreName.PARAM_DOCUMENT_NOT_NORMAL_CAR, searchConditions.DocumentNotNomalCar);
                //DbManager.Add(DWC003StoreName.PARAM_DOCUMENT_NOT_NORMAL_CAR, searchConditions.DocumentStocktaking);
                DbManager.Add(DWC003StoreName.PARAM_MODE_SEARCH, searchConditions.Mode);
				DbManager.Add( DWC003StoreName.PARAM_PAGE_INDEX, searchConditions.PageIndex );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_SIZE, searchConditions.PageSize );

				DataTable tableResult = DbManager.GetDataTable();
				rowCount = tableResult.Rows.Count;

				return Entities.EntityHelper<DCW003Result>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Get uketori detail
		/// </summary>
		/// <param name="lstDocControlNo"></param>
		/// <returns></returns>
		public List<DCW003UketoriDetail> DCW003GetUketoriDetail( List<string> lstDocControlNo )
		{
			DataTable tblDocControlNo = new DataTable();
			tblDocControlNo.Columns.Add( "DocControlNo", typeof( string ) );

			foreach (var item in lstDocControlNo)
			{
				DataRow row = tblDocControlNo.NewRow();
				row["DocControlNo"] = item;
				tblDocControlNo.Rows.Add( row );
			}
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_FUZOKUHIN ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_DOC_CONTROL_NO, SqlDbType.Structured, tblDocControlNo);
				DataTable tableResult = DbManager.GetDataTable();

				return Entities.EntityHelper<DCW003UketoriDetail>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Insert Doc Uketori Detail IF
		/// </summary>
		/// <param name="lstCsv"></param>
		/// <param name="errMsg"></param>
		public void DCW003InsertDocUketoriIf( List<DCW003CsvModel> lstCsv, out string errMsg )
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_INSERT_DOC_UKETORI_IF ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable( lstCsv ) );
				DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );
				DbManager.Add( DWC003StoreName.PARAM_ERROR_MSG, SqlDbType.VarChar, 8000, ParameterDirection.Output );

				DbManager.ExecuteNonQuery();

				// Output error message
				errMsg = DbManager.GetValueInString( DWC003StoreName.PARAM_ERROR_MSG );
			}
		}

		/// <summary>
		/// Insert Doc Control
		/// </summary>
		/// <param name="lstCsv"></param>
		/// <param name="lstError"></param>
		/// <param name="lstNoMap"></param>
		/// <param name="lstImport"></param>
        public void DCW003ImportCsv(List<DCW003CsvModel> lstCsv, out string lstError, out string lstErrorExist, out string lstNoMap, out string lstImport, out string lstDocControlNo)
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_IMPORT_CSV ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable( lstCsv ) );
				DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );
				DbManager.Add( DWC003StoreName.PARAM_LIST_ERROR, SqlDbType.VarChar, 8000, ParameterDirection.Output );
                DbManager.Add(DWC003StoreName.PARAM_LIST_ERROR_EXIST, SqlDbType.VarChar, 8000, ParameterDirection.Output);
				DbManager.Add( DWC003StoreName.PARAM_LIST_NO_MAP, SqlDbType.VarChar, 8000, ParameterDirection.Output );
				DbManager.Add( DWC003StoreName.PARAM_LIST_IMPORT, SqlDbType.VarChar, 8000, ParameterDirection.Output );
				DbManager.Add( DWC003StoreName.PARAM_LIST_DOC_CONTROL_NO, SqlDbType.VarChar, 8000, ParameterDirection.Output );

				DbManager.ExecuteNonQuery();

				// Output error message
				lstError = DbManager.GetValueInString( DWC003StoreName.PARAM_LIST_ERROR );
                lstErrorExist = DbManager.GetValueInString(DWC003StoreName.PARAM_LIST_ERROR_EXIST);
				lstNoMap = DbManager.GetValueInString( DWC003StoreName.PARAM_LIST_NO_MAP );
				lstImport = DbManager.GetValueInString( DWC003StoreName.PARAM_LIST_IMPORT );
				lstDocControlNo = DbManager.GetValueInString( DWC003StoreName.PARAM_LIST_DOC_CONTROL_NO );
			}
		}

		/// <summary>
		/// Get list import
		/// </summary>
		/// <param name="lstDocControlNo"></param>
		/// <returns></returns>
		public List<DCW003Result> DCW003GetListImport( List<string> lstDocControlNo , int pageIndex, int pageSize, out int rowCount )
		{
			DataTable tblDocControlNo = new DataTable();
			tblDocControlNo.Columns.Add( "DocControlNo", typeof( string ) );

			foreach (var item in lstDocControlNo)
			{
				DataRow row = tblDocControlNo.NewRow();
				row["DocControlNo"] = item;
				tblDocControlNo.Rows.Add( row );
			}

			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_LIST_IMPORT ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_DOC_CONTROL_NO, SqlDbType.Structured, tblDocControlNo );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_INDEX, pageIndex );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_SIZE, pageSize );
				DataTable tableResult = DbManager.GetDataTable();
				rowCount = tableResult.Rows.Count;

				return Entities.EntityHelper<DCW003Result>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Get Doc Control Exist
		/// </summary>
		/// <param name="lstCsv"></param>
		/// <param name="modeSearch"></param>
		/// <returns></returns>
		public List<DCW003Result> DCW003GetDocControlExist( List<DCW003CsvModel> lstCsv, int pageIndex, int pageSize, int modeSearch , out int rowCount)
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_DOC_CONTROL_EXIST ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable( lstCsv ) );
				DbManager.Add( DWC003StoreName.PARAM_MODE_SEARCH, modeSearch );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_INDEX, pageIndex );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_SIZE, pageSize );
				DataTable tableResult = DbManager.GetDataTable();
				rowCount = tableResult.Rows.Count;

				return Entities.EntityHelper<DCW003Result>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Get doc control from master
		/// </summary>
		/// <param name="lstRfid"></param>
		/// <returns></returns>
		public List<DCW003Result> DCW003GetDocControlMaster( List<DCW003RFID> lstRfid, int pageIndex, int pageSize, out int rowCount )
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_DOC_CONTROL_MASTER ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_RFID, SqlDbType.Structured, EntityHelper<DCW003RFID>.ConvertToDataTable( lstRfid ) );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_INDEX, pageIndex );
				DbManager.Add( DWC003StoreName.PARAM_PAGE_SIZE, pageSize );
				DataTable tableResult = DbManager.GetDataTable();
				rowCount = tableResult.Rows.Count;

				return Entities.EntityHelper<DCW003Result>.GetListObject( tableResult );
			}
		}


        public List<DCW003Result> DCW003GetHensoIfExist(List<DCW003CsvModel> lstCsv, int pageIndex, int pageSize, int modeSearch, out int rowCount)
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_GET_HENSO_IF_EXIST))
            {
                DbManager.Add(DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable(lstCsv));
                DbManager.Add(DWC003StoreName.PARAM_MODE_SEARCH, modeSearch);
                DbManager.Add(DWC003StoreName.PARAM_PAGE_INDEX, pageIndex);
                DbManager.Add(DWC003StoreName.PARAM_PAGE_SIZE, pageSize);
                DataTable tableResult = DbManager.GetDataTable();
                rowCount = tableResult.Rows.Count;

                return Entities.EntityHelper<DCW003Result>.GetListObject(tableResult);
            }
        }

		/// <summary>
		/// Get year master
		/// </summary>
		/// <param name="lstRfid"></param>
		/// <param name="pageIndex"></param>
		/// <param name="pageSize"></param>
		/// <param name="rowCount"></param>
		/// <returns></returns>
		public List<DCW003DropDownModel> DCW003GetMasterYear()
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_MASTER_YEAR ))
			{
				DataTable tableResult = DbManager.GetDataTable();

				return Entities.EntityHelper<DCW003DropDownModel>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Get master doc status
		/// </summary>
		/// <returns></returns>
		public List<DCW003DropDownModel> DCW003GetMasterDocStatus()
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_GET_MASTER_DOC_STATUS ))
			{
				DataTable tableResult = DbManager.GetDataTable();

				return Entities.EntityHelper<DCW003DropDownModel>.GetListObject( tableResult );
			}
		}

		/// <summary>
		/// Update one record
		/// </summary>
		/// <param name="result"></param>
		/// <param name="errorMsg"></param>
		//Edit fix bug 66 HoaVV start
        public DCW003ListReturnUpdate DCW003Update(DCW003Result result, out string errorMsg)
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_UPDATE_DOC_CONTROL ))
			{
				DbManager.Add( DWC003StoreName.PARAM_DOC_CONTROL_NO, result.DocControlNo );
				DbManager.Add( DWC003StoreName.PARAM_URIAGE_SHUPPINN_TOROKUNO, result.UriageShuppinnTorokuNo );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_FLG, result.MasshoFlg );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_FLG, result.JishameiFlg );
				DbManager.Add( DWC003StoreName.PARAM_DOC_STATUS, result.DocStatus );
				DbManager.Add( DWC003StoreName.PARAM_DOC_NYUKO_DATE, result.DocNyukoDate );
				DbManager.Add( DWC003StoreName.PARAM_DOC_SHUKKO_DATE, result.DocShukkoDate );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_IRAI_SHUKKO_DATE, result.JishameiIraiShukkoDate );
				DbManager.Add( DWC003StoreName.PARAM_JISHAMEI_KANRYO_NYUKO_DATE, result.JishameiKanryoNyukoDate );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_IRAI_SHUKKO_DATE, result.MasshoIraiShukkoDate );
				DbManager.Add( DWC003StoreName.PARAM_MASSHO_KANRYO_NYUKO_DATE, result.MasshoKanryoNyukoDate );
				DbManager.Add( DWC003StoreName.PARAM_MEMO, result.Memo );
                DbManager.Add(DWC003StoreName.PARAM_SHORUI_LIMIT_DATE, result.ShoruiLimitDate);
                DbManager.Add(DWC003StoreName.PARAM_SHAKEN_LIMIT_DATE, result.ShakenLimitDate);
                DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );
				DbManager.Add( DWC003StoreName.PARAM_ERROR_MSG, SqlDbType.VarChar, 5, ParameterDirection.Output );

				DbManager.ExecuteNonQuery();
				
                DataTable tableResult = DbManager.GetDataTable();
                // Output error message
                errorMsg = DbManager.GetValueInString(DWC003StoreName.PARAM_ERROR_MSG);

                return Entities.EntityHelper<DCW003ListReturnUpdate>.GetListObject(tableResult)[0];
				
				
			}
		}

		/// <summary>
		/// Update all
		/// </summary>
		/// <param name="lstUpdate"></param>
		public void DCW003UpdateAll( List<DCW003Update> lstUpdate)
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_UPDATE_ALL_DOC_CONTROL ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_UPDATE, SqlDbType.Structured, EntityHelper<DCW003Update>.ConvertToDataTable( lstUpdate ) );
				DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );
				
				DbManager.ExecuteNonQuery();
			}
		}

		/// <summary>
		/// Insert auto search
		/// </summary>
		/// <param name="lstUpdate"></param>
		public void DCW003InsertAutoSearch( List<DCW003Update> lstUpdate, out string lstSuccess, out string lstError)
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_INSERT_AUTO_SEARCH ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_UPDATE, SqlDbType.Structured, EntityHelper<DCW003Update>.ConvertToDataTable( lstUpdate ) );
				DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );
				DbManager.Add( DWC003StoreName.PARAM_LIST_SUCCESS, SqlDbType.VarChar, 8000, ParameterDirection.Output );
				DbManager.Add( DWC003StoreName.PARAM_LIST_ERROR, SqlDbType.VarChar, 8000, ParameterDirection.Output );

				DbManager.ExecuteNonQuery();

				lstSuccess = DbManager.GetValueInString( DWC003StoreName.PARAM_LIST_SUCCESS );
				lstError = DbManager.GetValueInString( DWC003StoreName.PARAM_LIST_ERROR );
			}
		}

		/// <summary>
		/// Insert Jishamei Massho
		/// </summary>
		/// <param name="lstCsv"></param>
		public void DCW003InsertJishameiMassho( List<DCW003CsvModel> lstCsv)
		{
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_INSERT_JISHAMEI_MASSHO ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable( lstCsv ) );
				DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );

				DbManager.ExecuteNonQuery();
			}
		}

        public void DCW003InsertHisUketoriDetail(List<string> lst)
        {
            DataTable tblDocControlNo = new DataTable();
            tblDocControlNo.Columns.Add("DocControlNo", typeof(string));

            foreach (var item in lst)
            {
                DataRow row = tblDocControlNo.NewRow();
                row["DocControlNo"] = item;
                tblDocControlNo.Rows.Add(row);
            }
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_INSERT_HIS_UKETORI_DETAIL))
            {
                DbManager.Add(DWC003StoreName.PARAM_LIST_DOC_CONTROL_NO, SqlDbType.Structured, tblDocControlNo);
                DbManager.Add(DWC003StoreName.PARAM_USER, CmnEntityModel.UserName);
                DbManager.ExecuteNonQuery();
            }
        }


		/// <summary>
		/// Insert uketori detail
		/// </summary>
		/// <param name="lstFuzokuhin"></param>
		/// <param name="errMsg"></param>
		public void DCW003InsertDocUketoriDetail(List<DCW003UketoriUpdate> lstUpdate, List<DCW003UketoriDetail> lstDetail, out string errMsg )
		{
			DataTable tblDetail = new DataTable();
			tblDetail = EntityHelper<DCW003UketoriDetail>.ConvertToDataTable( lstDetail );
			if (tblDetail == null)
			{
				tblDetail = new DataTable();
				tblDetail.Columns.Add( "DocControlNo", typeof( string ) );
				tblDetail.Columns.Add( "DocFuzokuhinCd", typeof( string ) );
                tblDetail.Columns.Add("DefaulCheckType", typeof(string));
                tblDetail.Columns.Add("HisUketoriDocControlNo", typeof(string));
                tblDetail.Columns.Add("DocCount", typeof(int));
				tblDetail.Columns.Add( "Note", typeof( string ) );
				tblDetail.Columns.Add( "IsChecked", typeof( int ) );
			}
			using (DBManager DbManager = new DBManager( DWC003StoreName.STP_DCW003_INSERT_DOC_UKETORI_DETAIL ))
			{
				DbManager.Add( DWC003StoreName.PARAM_LIST_UKETORI_UPDATE, SqlDbType.Structured, EntityHelper<DCW003UketoriUpdate>.ConvertToDataTable( lstUpdate ) );
				DbManager.Add( DWC003StoreName.PARAM_LIST_UKETORI_DETAIL, SqlDbType.Structured,tblDetail );
				DbManager.Add( DWC003StoreName.PARAM_USER, CmnEntityModel.UserName );
				DbManager.Add( DWC003StoreName.PARAM_ERROR_MSG, SqlDbType.VarChar, 8000, ParameterDirection.Output );

				DbManager.ExecuteNonQuery();

				// Output error message
				errMsg = DbManager.GetValueInString( DWC003StoreName.PARAM_ERROR_MSG );
			}
		}
		//TRAMD ADD PHASE 2 IMPORT 5
        public void DCW003InsertHensoIf(List<DCW003CsvModel> lstCsvTempHenso)
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_INSERT_HENSO_IF))
            {
                DbManager.Add(DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable(lstCsvTempHenso));
                DbManager.Add(DWC003StoreName.PARAM_USER, CmnEntityModel.UserName);

                DbManager.ExecuteNonQuery();
            }
        }
		//END
		
		//HOA ADD PHASE 2 IMPORT 5
        public void DCW003SendToGHQ(List<DCW003UketoriUpdateSendGHQ> lstSendGHQ, out string errMsg)
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_SEND_TO_GHQ))
            {
                DbManager.Add(DWC003StoreName.PARAM_LIST_SEND_GHQ, SqlDbType.Structured, EntityHelper<DCW003UketoriUpdateSendGHQ>.ConvertToDataTable(lstSendGHQ));
                DbManager.Add(DWC003StoreName.PARAM_USER, CmnEntityModel.UserName);
                DbManager.Add(DWC003StoreName.PARAM_ERROR_MSG, SqlDbType.VarChar, 5, ParameterDirection.Output);
                DbManager.ExecuteNonQuery();
                // Output error message
                errMsg = DbManager.GetValueInString(DWC003StoreName.PARAM_ERROR_MSG);
            }
        }

        public void DCW003ExportCSVLinkGHQ(List<DCW003UketoriExportCSVLinkGHQ> lstExportCSVLinkGHQ, out string errMsg)
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_EXPORT_CSV_LINK_GHQ))
            {
                DbManager.Add(DWC003StoreName.PARAM_EXPORT_CSV_LINK_GHQ, SqlDbType.Structured, EntityHelper<DCW003UketoriExportCSVLinkGHQ>.ConvertToDataTable(lstExportCSVLinkGHQ));
                DbManager.Add(DWC003StoreName.PARAM_USER, CmnEntityModel.UserName);
                DbManager.Add(DWC003StoreName.PARAM_ERROR_MSG, SqlDbType.VarChar, 5, ParameterDirection.Output);
                DbManager.ExecuteNonQuery();
                // Output error message
                errMsg = DbManager.GetValueInString(DWC003StoreName.PARAM_ERROR_MSG);
            }
        }
		//Add fix bug 66 HoaVV end
        // <summary>
        /// Check InputTorokuno
        /// </summary>
        /// <param name="lstFuzokuhin"></param>
        /// <param name="errMsg"></param>
        public void DCW003CheckInputTorokuno(string UriageShuppinnTorokuNo, string DocControlNo, out string errorMsg)
        {

            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_CHECK_INPUT_TOROKUNO))
            {
                DbManager.Add(DWC003StoreName.PARAM_DOC_CONTROL_NO, DocControlNo);
                DbManager.Add(DWC003StoreName.PARAM_URIAGE_SHUPPINN_TOROKUNO, UriageShuppinnTorokuNo);
                DbManager.Add(DWC003StoreName.PARAM_USER, CmnEntityModel.UserName);
                DbManager.Add(DWC003StoreName.PARAM_ERROR_MSG, SqlDbType.VarChar, 5, ParameterDirection.Output);

                DbManager.ExecuteNonQuery();

                // Output error message
                errorMsg = DbManager.GetValueInString(DWC003StoreName.PARAM_ERROR_MSG);
            }
        }
	//Add fix bug 66 HoaVV end
        /// <summary>
        /// Get master JapanYear
        /// </summary>
        /// <returns></returns>
        public List<DCW003JapanYear> DCW003GetJapanYear()
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_GET_Japan_YEAR))
            {
                DataTable tableResult = DbManager.GetDataTable();

                return Entities.EntityHelper<DCW003JapanYear>.GetListObject(tableResult);
            }
        }
		//END



        public List<DCW003CsvModel> DCW003GetHensoIfExist()
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_GET_HENSO_IF))
            {
                DataTable tableResult = DbManager.GetDataTable();

                return Entities.EntityHelper<DCW003CsvModel>.GetListObject(tableResult);
            }
        }

        public void UpdateHensoIf()
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_UPDATE_HENSO_IF))
            {
                DbManager.ExecuteNonQuery();
            }
        }

        public List<DCW003Result> DCW003GetHensoIf(List<DCW003CsvModel> lstCsv, int pageIndex, int pageSize, int modeSearch, out int rowCount)
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_GET_HENSO_IF))
            {
                DbManager.Add(DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable(lstCsv));
                DbManager.Add(DWC003StoreName.PARAM_MODE_SEARCH, modeSearch);
                DbManager.Add(DWC003StoreName.PARAM_PAGE_INDEX, pageIndex);
                DbManager.Add(DWC003StoreName.PARAM_PAGE_SIZE, pageSize);
                DataTable tableResult = DbManager.GetDataTable();
                rowCount = tableResult.Rows.Count;
                return Entities.EntityHelper<DCW003Result>.GetListObject(tableResult);
            }
        }

        public List<DCW003Result> DCW003GetHenSoIf(List<DCW003CsvModel> lstCsv, int pageIndex, int pageSize, int modeSearch, out int rowCount)
        {
            using (DBManager DbManager = new DBManager(DWC003StoreName.STP_DCW003_GET_HENSO_IF))
            {
                DbManager.Add(DWC003StoreName.PARAM_LIST_CSV, SqlDbType.Structured, EntityHelper<DCW003CsvModel>.ConvertToDataTable(lstCsv));
                DbManager.Add(DWC003StoreName.PARAM_MODE_SEARCH, modeSearch);
                DbManager.Add(DWC003StoreName.PARAM_PAGE_INDEX, pageIndex);
                DbManager.Add(DWC003StoreName.PARAM_PAGE_SIZE, pageSize);
                DataTable tableResult = DbManager.GetDataTable();
                rowCount = tableResult.Rows.Count;
                return Entities.EntityHelper<DCW003Result>.GetListObject(tableResult);
            }
        }
    }
}
