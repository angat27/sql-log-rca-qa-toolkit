-- ============================================================================
-- Enterprise FinTech & Banking QA - Data Integrity & Reconciliation Checks
-- ============================================================================

-- 1. Check for orphaned transactions (transactions without a valid account)
SELECT t.transaction_id, t.account_id, t.amount, t.created_at
FROM transactions t
LEFT JOIN accounts a ON t.account_id = a.account_id
WHERE a.account_id IS NULL;

-- 2. Detect duplicate payment entries within a 1-minute window (Idempotency check)
SELECT account_id, amount, currency, COUNT(*) AS duplicate_count, MIN(created_at) AS first_seen
FROM transactions
WHERE status = 'COMPLETED'
GROUP BY account_id, amount, currency, DATE_TRUNC('minute', created_at)
HAVING COUNT(*) > 1;

-- 3. Balance reconciliation: Compare ledger sum against cached account balance
SELECT 
    a.account_id,
    a.current_balance AS recorded_balance,
    COALESCE(SUM(CASE WHEN t.type = 'CREDIT' THEN t.amount ELSE -t.amount END), 0) AS calculated_balance,
    (a.current_balance - COALESCE(SUM(CASE WHEN t.type = 'CREDIT' THEN t.amount ELSE -t.amount END), 0)) AS discrepancy
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id AND t.status = 'COMPLETED'
GROUP BY a.account_id, a.current_balance
HAVING a.current_balance <> COALESCE(SUM(CASE WHEN t.type = 'CREDIT' THEN t.amount ELSE -t.amount END), 0);

-- 4. Identify stuck transactions remaining in 'PENDING' state for over 30 minutes
SELECT transaction_id, account_id, amount, status, created_at
FROM transactions
WHERE status = 'PENDING'
  AND created_at < NOW() - INTERVAL '30 minutes'
ORDER BY created_at ASC;
