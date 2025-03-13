import express from "express";
import { 
  addFinancialRecord, 
  getFinancialRecords, 
  updateFinancialRecord, 
  softDeleteFinancialRecord,
  restoreFinancialRecord,
  getAuditLogs
} from "../controllers/finance.controller.js";
import {authorize} from "../middlewares/authorize.middleware.js";
import {verifyJWT} from "../middlewares/auth.middleware.js";

const router = express.Router();

// ✅ Admin Only - Can Add Financial Records
router.post("/", verifyJWT, authorize(["admin"]), addFinancialRecord);

// ✅ Admin, Coaches & Athletes - Can View Financial Records
router.get("/", verifyJWT, authorize(["admin", "coach", "athlete"]), getFinancialRecords);

router.get("/:athleteId", verifyJWT, authorize(["admin", "coach", "athlete"]), getFinancialRecords);


// ✅ Admin Only - Can Update Financial Records
router.put("/:id", verifyJWT, authorize(["admin"]), updateFinancialRecord);

// ✅ Admin Only - Can Delete Financial Records
router.delete("/:id", verifyJWT, authorize(["admin"]), softDeleteFinancialRecord);


// ✅ Admin Only - Can Restore Financial Records
router.put("/:id/restore", verifyJWT, authorize(["admin"]), restoreFinancialRecord);

router.get("/audit-logs", verifyJWT, authorize(["admin"]), getAuditLogs);


export default router;
