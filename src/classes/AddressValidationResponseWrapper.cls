public class AddressValidationResponseWrapper{

    public class AddressValidationWrapper{
        public String returnCodes;
        public String details;
        public returnDatasetWrapper returnDataset;
        public returnBlkAddrDatasetWrapper returnBlkAddrDataset;
        
        public AddressValidationWrapper(String returnCodes ,String details) {
            this.returnCodes= returnCodes;
            this.details= details;         
        }
    }
    
    public class TableWrapper{
        public String ADDRESS_ID;
        public String FULLADDRESS;
        public String CITY;
        public String STATE;
        public String ZIPCODE;
        public String LATITUDE;
        public String LONGITUDE;
        public String ALIASNAME;
        // holds intersection details
        public String INTERSECTIONID;
        public String FULLINTERSECTION;
        public String ROADWAYSEGID;
        public String REFX;
        public String REFY;
        public String MARID;
        
        //holds blkaddress fields
        public String FULLBLOCK;
        public String BLOCKNAME;
        public String LOWER_RANGE;
        public String HIGHER_RANGE;
        public String CENTROIDX;
        public String CENTROIDY;
        
        // Extra fields included DM 2709
        public string QUADRANT;
        public string XCOORD;
        public string YCOORD;
        public string ANC;
        public string PSA;
        public string WARD;
        public string SMD;
        
        public string POLDIST;
        public string CLUSTER;        
        public string ADDRNUM;    

        public String SNOWAREA;
        public String SNOWZONE;
        
        // three more fields need to add DISTRICT And Neighbound
        //public string 
        //public string CLUSTER_;
        //overloading constructor
        public TableWrapper(String ADDRESS_ID,String FULLADDRESS, String CITY,String STATE,String ZIPCODE,String LATITUDE,String LONGITUDE,String ALIASNAME,String INTERSECTIONID,String FULLINTERSECTION,String ROADWAYSEGID,String QUADRANT,String XCOORD,String YCOORD,String ANC,String PSA,String WARD,String SMD,String POLDIST,String CLUSTER,String ADDRNUM,String FULLBLOCK,String BLOCKNAME,String LOWER_RANGE,String HIGHER_RANGE,String REFX,String REFY,String CENTROIDX,String CENTROIDY, String MARID) {
            this.ADDRESS_ID= ADDRESS_ID;
            this.FULLADDRESS= FULLADDRESS;
            this.CITY= CITY;
            this.STATE= STATE;
            this.ZIPCODE= ZIPCODE;
            this.LATITUDE= LATITUDE;
            this.LONGITUDE= LONGITUDE;
            this.ALIASNAME= ALIASNAME;
            this.INTERSECTIONID = INTERSECTIONID;
            this.FULLINTERSECTION = FULLINTERSECTION;
            this.ROADWAYSEGID = ROADWAYSEGID;
            this.QUADRANT=QUADRANT;
            this.XCOORD=XCOORD;
            this.YCOORD=YCOORD;
            this.ANC=ANC;
            this.PSA=PSA;
            this.WARD=WARD;
            this.SMD=SMD;
            this.POLDIST=POLDIST;
            this.CLUSTER=CLUSTER;
            this.FULLBLOCK=FULLBLOCK;
            this.BLOCKNAME=BLOCKNAME;
            this.LOWER_RANGE=LOWER_RANGE;
            this.HIGHER_RANGE=HIGHER_RANGE;
            this.ADDRNUM=ADDRNUM;
            this.REFX=REFX;
            this.REFY=REFY;
            this.CENTROIDX=CENTROIDX;
            this.CENTROIDY=CENTROIDY;
            this.MARID = MARID;
            this.SNOWZONE = '';
            this.SNOWAREA = '';      
        }        
        
    }     
   
    public class returnDatasetWrapper{
      
        public TableWrapper[] Table1;
        
        public returnDatasetWrapper() {           
                this.Table1= new List<TableWrapper>();
        }
    }
    
    public class returnBlkAddrDatasetWrapper {
      
        public TableWrapper[] Table1;

        public returnBlkAddrDatasetWrapper () {           
                this.Table1= new List<TableWrapper>();

        }
    }
}