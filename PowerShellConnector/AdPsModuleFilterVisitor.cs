/*
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
 *
 * Copyright (c) 2014-2016 ForgeRock AS. All Rights Reserved
 *
 * The contents of this file are subject to the terms
 * of the Common Development and Distribution License
 * (the License). You may not use this file except in
 * compliance with the License.
 *
 * You can obtain a copy of the License at
 * http://forgerock.org/license/CDDLv1.0.html
 * See the License for the specific language governing
 * permission and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL
 * Header Notice in each file and include the License file
 * at http://forgerock.org/license/CDDLv1.0.html
 * If applicable, add the following below the CDDL Header,
 * with the fields enclosed by brackets [] replaced by
 * your own identifying information:
 * "Portions Copyrighted [year] [name of copyright owner]"
 */


using System;
using System.Collections.Generic;
using Org.IdentityConnectors.Framework.Common.Objects.Filters;

namespace Org.ForgeRock.OpenICF.Connectors.MsPowerShell
{
    class AdPsModuleFilterVisitor : FilterVisitor<string, Dictionary<string, string>>
    {
        /// <summary>
        /// AndFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitAndFilter(Dictionary<string, string> p, AndFilter filter)
        {
            var l = filter.Left.Accept<string, Dictionary<string, string>>(this, p);
            var r = filter.Right.Accept<string, Dictionary<string, string>>(this, p);
            return String.Format("{0} -and {1}", l, r);
        }

        /// <summary>
        /// VisitContainsFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitContainsFilter(Dictionary<string, string> p, ContainsFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -like \"{1}{2}{3}\"", name, "*", filter.GetValue(), "*");
        }

        public string VisitContainsAllValuesFilter(Dictionary<string, string> p, ContainsAllValuesFilter filter)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// VisitEqualsFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <exception cref="NotImplementedException"></exception>
        /// <returns></returns>
        public string VisitEqualsFilter(Dictionary<string, string> p, EqualsFilter filter)
        {
            string name = filter.GetAttribute().Name;
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            var values = filter.GetAttribute().Value;
            if (values.Count == 1)
            {
                return String.Format("{0} -eq \"{1}\"", name, values[0]);
            }
            throw new NotImplementedException("Equality visitor does not implement multi value attributes");
        }

        public string VisitExtendedFilter(Dictionary<string, string> p, Filter filter)
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// VisitGreaterThanFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitGreaterThanFilter(Dictionary<string, string> p, GreaterThanFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -gt {1}", name, filter.GetValue());
        }

        /// <summary>
        /// VisitGreaterThanOrEqualFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitGreaterThanOrEqualFilter(Dictionary<string, string> p, GreaterThanOrEqualFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -ge {1}", name, filter.GetValue());
        }

        /// <summary>
        /// VisitLessThanFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitLessThanFilter(Dictionary<string, string> p, LessThanFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -lt {1}", name, filter.GetValue());
        }

        /// <summary>
        /// VisitLessThanOrEqualFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitLessThanOrEqualFilter(Dictionary<string, string> p, LessThanOrEqualFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -le {1}", name, filter.GetValue());
        }

        /// <summary>
        /// VisitNotFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitNotFilter(Dictionary<string, string> p, NotFilter filter)
        {
            return String.Format("-not {0}", filter.Filter.Accept(this, p));
        }

        /// <summary>
        /// VisitOrFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitOrFilter(Dictionary<string, string> p, OrFilter filter)
        {
            var l = filter.Left.Accept<string, Dictionary<string, string>>(this, p);
            var r = filter.Right.Accept<string, Dictionary<string, string>>(this, p);
            return String.Format("{0} -or {1}", l, r);
        }

        /// <summary>
        /// VisitStartsWithFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitStartsWithFilter(Dictionary<string, string> p, StartsWithFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -like \"{1}{2}\"", name, filter.GetValue(), "*");
        }

        /// <summary>
        /// VisitEndsWithFilter
        /// </summary>
        /// <param name="p"></param>
        /// <param name="filter"></param>
        /// <returns></returns>
        public string VisitEndsWithFilter(Dictionary<string, string> p, EndsWithFilter filter)
        {
            string name = filter.GetName();
            if (p.ContainsKey(name))
            {
                name = p[name];
            }
            return String.Format("{0} -like \"{1}{2}\"", name, "*", filter.GetValue());
        }
    }
}
