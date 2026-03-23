module.exports = function handler(req, res) {
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');

  const supabaseUrl = process.env.SUPABASE_URL || '';
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || '';

  if (!supabaseUrl || !supabaseAnonKey) {
    return res.status(200).json({ SUPABASE_URL: '', SUPABASE_KEY: '' });
  }

  return res.status(200).json({
    SUPABASE_URL: supabaseUrl,
    SUPABASE_KEY: supabaseAnonKey
  });
};
