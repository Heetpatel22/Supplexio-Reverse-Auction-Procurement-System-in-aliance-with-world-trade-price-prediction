"""
trend_analysis.py
Trend Analysis and Forecasting Module

Provides:
- Historical trend analysis
- Simple forecasting (ARIMA-like, exponential smoothing)
- Growth rate calculations
- Year-over-year comparisons
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import warnings

warnings.filterwarnings("ignore")

class TrendAnalyzer:
    """Analyze trade trends and generate forecasts"""
    
    @staticmethod
    def calculate_growth_rate(current_value, previous_value):
        """Calculate growth percentage"""
        if previous_value == 0 or pd.isna(previous_value):
            return 0
        return ((current_value - previous_value) / abs(previous_value)) * 100
    
    @staticmethod
    def analyze_time_series(df, date_column, value_column):
        """Analyze a time series for trends
        
        Returns:
            dict with trend info
        """
        if df.empty:
            return {
                'trend': 'No Data',
                'growth_rate': 0,
                'min': 0,
                'max': 0,
                'avg': 0,
                'latest': 0
            }
        
        try:
            df = df.sort_values(by=date_column)
            values = pd.to_numeric(df[value_column], errors='coerce').dropna()
            
            if len(values) < 2:
                return {
                    'trend': 'Insufficient Data',
                    'growth_rate': 0,
                    'min': float(values.min()) if len(values) > 0 else 0,
                    'max': float(values.max()) if len(values) > 0 else 0,
                    'avg': float(values.mean()) if len(values) > 0 else 0,
                    'latest': float(values.iloc[-1]) if len(values) > 0 else 0
                }
            
            # Calculate growth rate
            growth_rate = TrendAnalyzer.calculate_growth_rate(values.iloc[-1], values.iloc[0])
            
            # Determine trend
            if growth_rate > 5:
                trend = 'Upward Trend ↗'
            elif growth_rate < -5:
                trend = 'Downward Trend ↘'
            else:
                trend = 'Stable'
            
            return {
                'trend': trend,
                'growth_rate': round(growth_rate, 2),
                'min': float(values.min()),
                'max': float(values.max()),
                'avg': float(values.mean()),
                'latest': float(values.iloc[-1]),
                'data_points': len(values)
            }
        
        except Exception as e:
            return {
                'trend': 'Error',
                'error': str(e),
                'growth_rate': 0
            }
    
    @staticmethod
    def simple_forecast(values, periods=3, method='linear'):
        """Simple forecasting method
        
        Args:
            values: list or array of historical values
            periods: number of periods to forecast
            method: 'linear', 'exponential', or 'average'
        
        Returns:
            list of forecasted values
        """
        if len(values) < 2:
            return [values[-1]] * periods
        
        values = np.array([float(v) for v in values if pd.notna(v)])
        
        if len(values) == 0:
            return [0] * periods
        
        if method == 'linear':
            # Simple linear trend
            x = np.arange(len(values))
            y = values
            coeffs = np.polyfit(x, y, 1)
            forecast_x = np.arange(len(values), len(values) + periods)
            forecast = np.polyval(coeffs, forecast_x)
            return [max(0, f) for f in forecast]
        
        elif method == 'exponential':
            # Exponential smoothing-like
            last_value = values[-1]
            avg_growth = (values[-1] - values[0]) / len(values) if len(values) > 1 else 0
            forecast = []
            for i in range(periods):
                forecast_val = last_value + (avg_growth * (i + 1))
                forecast.append(max(0, forecast_val))
            return forecast
        
        else:  # average
            # Average of recent values
            recent_avg = np.mean(values[-min(3, len(values)):])
            return [recent_avg] * periods
    
    @staticmethod
    def project_future_values(historical_df, date_column, value_column, months_ahead=6):
        """Project future trade values
        
        Args:
            historical_df: DataFrame with historical data
            date_column: name of date column
            value_column: name of value column to forecast
            months_ahead: how many months to forecast
        
        Returns:
            DataFrame with historical and projected values
        """
        if historical_df.empty:
            return pd.DataFrame()
        
        try:
            # Sort by date
            df = historical_df.sort_values(by=date_column)
            
            # Get values
            values = pd.to_numeric(df[value_column], errors='coerce').values
            
            # Generate forecast
            forecast = TrendAnalyzer.simple_forecast(values, periods=months_ahead, method='linear')
            
            # Create forecast dates (simplified - using numeric progression)
            last_date = pd.to_datetime(df[date_column].iloc[-1], errors='coerce')
            
            if pd.notna(last_date):
                forecast_dates = [
                    last_date + timedelta(days=30*i) for i in range(1, months_ahead + 1)
                ]
            else:
                forecast_dates = [f"Future_{i}" for i in range(1, months_ahead + 1)]
            
            # Create result DataFrame
            result = df.copy()
            result['Type'] = 'Historical'
            
            forecast_df = pd.DataFrame({
                date_column: forecast_dates,
                value_column: forecast,
                'Type': 'Forecast'
            })
            
            # Align columns
            for col in df.columns:
                if col not in forecast_df.columns:
                    forecast_df[col] = None
            
            result = pd.concat([result, forecast_df], ignore_index=True)
            
            return result
        
        except Exception as e:
            print(f"Error in forecast: {str(e)}")
            return historical_df
    
    @staticmethod
    def get_yoy_growth(df, date_column, value_column, group_by=None):
        """Calculate year-over-year growth
        
        Args:
            df: DataFrame
            date_column: date column name
            value_column: value column name
            group_by: column to group by (e.g., 'Country')
        
        Returns:
            DataFrame with YoY growth calculations
        """
        if df.empty:
            return pd.DataFrame()
        
        try:
            df = df.copy()
            df[date_column] = pd.to_datetime(df[date_column], errors='coerce')
            df['Year'] = df[date_column].dt.year
            df['Month'] = df[date_column].dt.month
            df[value_column] = pd.to_numeric(df[value_column], errors='coerce')
            
            if group_by:
                grouped = df.groupby([group_by, 'Year', 'Month'])[value_column].sum().reset_index()
            else:
                grouped = df.groupby(['Year', 'Month'])[value_column].sum().reset_index()
            
            return grouped
        
        except Exception as e:
            print(f"Error in YoY calculation: {str(e)}")
            return df
    
    @staticmethod
    def get_top_performers(df, value_column, group_by_column, top_n=10):
        """Get top performers by value
        
        Args:
            df: DataFrame
            value_column: column with values to sum
            group_by_column: column to group by
            top_n: number of top performers to return
        
        Returns:
            DataFrame with top performers
        """
        if df.empty:
            return pd.DataFrame()
        
        try:
            df = df.copy()
            df[value_column] = pd.to_numeric(df[value_column], errors='coerce')
            
            top = df.groupby(group_by_column)[value_column].sum().sort_values(ascending=False).head(top_n)
            
            return top
        
        except Exception as e:
            print(f"Error in top performers: {str(e)}")
            return pd.DataFrame()


if __name__ == "__main__":
    # Test the analyzer
    analyzer = TrendAnalyzer()
    
    # Create sample data
    dates = pd.date_range('2020-01-01', periods=24, freq='M')
    values = [100 + i*5 + np.random.rand()*10 for i in range(24)]
    
    df = pd.DataFrame({'Date': dates, 'Value': values})
    
    # Test trend analysis
    result = analyzer.analyze_time_series(df, 'Date', 'Value')
    print("Trend Analysis:", result)
    
    # Test forecast
    forecast = analyzer.simple_forecast(values, periods=6)
    print("\nForecast (next 6 months):", forecast)
    
    # Test projection
    projected = analyzer.project_future_values(df, 'Date', 'Value', months_ahead=6)
    print("\nProjected DataFrame shape:", projected.shape)
